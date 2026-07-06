<?php

namespace App\Jobs;

use App\Enums\OrderStatus;
use App\Models\Order;
use App\Models\User;
use App\Notifications\OrderAutoAssigned;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;

class AutoAssignTechnician implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    private const RADIUS_KM = 50;

    public function __construct(private Order $order)
    {
    }

    public function handle(): void
    {
        // Re-fetch from DB with a lock to prevent race conditions
        $order = DB::transaction(function () {
            $o = Order::lockForUpdate()->find($this->order->id);

            // Only proceed if still waiting for a technician
            if (! $o || $o->status !== OrderStatus::PENDING_TECH || $o->technician_id !== null) {
                return null;
            }

            return $o;
        });

        if (! $order) {
            return; // Already accepted by a technician — do nothing
        }

        $order->load('user', 'service');

        if (! $order->user?->lat || ! $order->user?->lng) {
            return; // No customer location — cannot find nearby technician
        }

        $customerLat = $order->user->lat;
        $customerLng = $order->user->lng;

        // Find all available technicians within radius and score them using AI multi-variable engine
        $technicians = User::selectRaw("
                users.*,
                ( 6371 * acos( cos( radians(?) ) *
                  cos( radians( users.lat ) )
                  * cos( radians( users.lng ) - radians(?) )
                  + sin( radians(?) ) *
                  sin( radians( users.lat ) ) )
                ) AS distance
            ", [$customerLat, $customerLng, $customerLat])
            ->join('service_user', 'service_user.user_id', '=', 'users.id')
            ->where('service_user.service_id', $order->service_id)
            ->where('users.is_technician', true)
            ->where('users.is_active', true)
            ->where('users.is_online', true)
            ->whereNotNull('users.lat')
            ->whereNotNull('users.lng')
            ->where('users.last_seen_at', '>=', now()->subMinutes(15))
            ->having('distance', '<', self::RADIUS_KM)
            ->withCount(['technicianOrders as active_orders_count' => function ($query) {
                $query->whereIn('status', [OrderStatus::ACCEPTED, OrderStatus::ON_THE_WAY, OrderStatus::IN_PROGRESS]);
            }])
            ->withCount(['technicianOrders as completed_orders_count' => function ($query) {
                $query->where('status', OrderStatus::COMPLETED);
            }])
            ->withAvg('technicianReviews as avg_tech_rating', 'avg_rating')
            ->get();

        if ($technicians->isEmpty()) {
            return; // No available technician in range
        }

        // AI Multi-Variable Scoring Algorithm (Distance: 40%, Rating: 30%, Workload: 20%, Experience: 10%)
        $technician = $technicians->sortByDesc(function ($tech) {
            $distanceScore = max(0, 40 - ($tech->distance * 1.5));
            $ratingScore = (($tech->avg_tech_rating ?? 5.0) / 5.0) * 30;
            $workloadScore = $tech->active_orders_count == 0 ? 20 : ($tech->active_orders_count == 1 ? 10 : 0);
            $experienceScore = min(10, $tech->completed_orders_count * 0.5);

            return $distanceScore + $ratingScore + $workloadScore + $experienceScore;
        })->first();

        if (! $technician) {
            return;
        }

        // Assign the technician inside a transaction
        DB::transaction(function () use ($order, $technician) {
            $fresh = Order::lockForUpdate()->find($order->id);

            // Double-check: another process might have assigned in the meantime
            if ($fresh->technician_id !== null || $fresh->status !== OrderStatus::PENDING_TECH) {
                return;
            }

            $fresh->update([
                'technician_id' => $technician->id,
                'status'        => OrderStatus::ACCEPTED,
            ]);

            // Notify technician
            $technician->notify(new OrderAutoAssigned($fresh, 'technician'));

            // Notify customer
            $order->user->notify(new OrderAutoAssigned($fresh, 'customer'));
        });
    }
}
