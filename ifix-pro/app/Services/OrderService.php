<?php

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use App\Enums\OrderStatus;
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

        return Order::create([
            ...$data,
            'user_id' => $customer->id,
            'status' => OrderStatus::PENDING_TECH,
        ]);
    }

    public function findNearbyTechnicians(float $lat, float $lng, int $radius = 50)
    {
        // Using raw Haversine formula to return distance in km (radius of earth ~6371km)
        return User::selectRaw(
            "id, name, phone, lat, lng,
            ( 6371 * acos( cos( radians(?) ) *
            cos( radians( lat ) )
            * cos( radians( lng ) - radians(?)
            ) + sin( radians(?) ) *
            sin( radians( lat ) ) )
            ) AS distance",
            [$lat, $lng, $lat]
        )
        ->whereNotNull('lat')
        ->whereNotNull('lng')
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
            $penalty = 50.00; // Fixed penalty fee
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
