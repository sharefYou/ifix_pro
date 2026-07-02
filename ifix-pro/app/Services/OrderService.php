<?php

namespace App\Services;

use App\Enums\OrderStatus;
use App\Jobs\AutoAssignTechnician;
use App\Jobs\NotifyNearbyTechnicians;
use App\Models\Order;
use App\Models\User;
use Exception;
use Illuminate\Support\Facades\DB;

class OrderService
{
    public function __construct(private WalletService $walletService)
    {
    }

    public function createOrder(User $customer, array $data): Order
    {
        $amount = (float) $data['total_amount'];

        $this->walletService->holdFunds($customer, $amount);

        $order = Order::create([
            ...$data,
            'user_id' => $customer->id,
            'status'  => OrderStatus::PENDING_TECH,
        ]);

        // 1. Notify nearby online technicians immediately
        NotifyNearbyTechnicians::dispatch($order);

        // 2. Auto-assign closest technician after 10 minutes if no one accepted
        AutoAssignTechnician::dispatch($order)->delay(now()->addMinutes(10));

        return $order;
    }

    /**
     * Find available technicians near a point, sorted by distance.
     * Only returns technicians who were seen in the last 5 minutes (fresh location).
     */
    public function findNearbyTechnicians(float $lat, float $lng, int $radius = 50)
    {
        return User::selectRaw("
                id, name, phone, lat, lng, last_seen_at,
                ( 6371 * acos( cos( radians(?) ) *
                  cos( radians( lat ) )
                  * cos( radians( lng ) - radians(?) )
                  + sin( radians(?) ) *
                  sin( radians( lat ) ) )
                ) AS distance
            ", [$lat, $lng, $lat])
            ->where('is_technician', true)
            ->where('is_active', true)
            ->where('is_online', true)
            ->whereNotNull('lat')
            ->whereNotNull('lng')
            ->where('last_seen_at', '>=', now()->subMinutes(5))
            ->having('distance', '<', $radius)
            ->orderBy('distance')
            ->get();
    }

    public function cancelOrder(Order $order): void
    {
        if ($order->status === OrderStatus::CANCELED) {
            throw new Exception('Order is already canceled.');
        }

        if ($order->status === OrderStatus::ON_THE_WAY) {
            $penalty = 50.00;
            $this->walletService->refundWithPenalty($order, $penalty);
        } else {
            $this->walletService->refundCustomer($order);
        }

        $order->update(['status' => OrderStatus::CANCELED]);
    }

    public function completeOrder(Order $order): void
    {
        if ($order->status === OrderStatus::COMPLETED || $order->status === OrderStatus::CANCELED) {
            throw new Exception('Order cannot be completed from its current status.');
        }

        $this->walletService->releaseFundsToTechnician($order);
        $order->update(['status' => OrderStatus::COMPLETED]);
    }
}
