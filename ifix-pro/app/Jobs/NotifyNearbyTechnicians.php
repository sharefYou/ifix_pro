<?php

namespace App\Jobs;

use App\Models\Order;
use App\Models\User;
use App\Notifications\NewOrderNearby;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;

class NotifyNearbyTechnicians implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    private const RADIUS_KM = 30;

    public function __construct(private Order $order)
    {
    }

    public function handle(): void
    {
        // Re-fetch order with service to avoid stale state
        $order = Order::with('service', 'user')->find($this->order->id);

        if (! $order || ! $order->user) {
            return;
        }

        $customerLat = $order->user->lat;
        $customerLng = $order->user->lng;

        if (! $customerLat || ! $customerLng) {
            return;
        }

        // Find online technicians within radius who offer this service
        // and have a valid FCM token and were seen in the last 10 minutes
        $technicians = User::selectRaw("
                users.id, users.fcm_token,
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
            ->whereNotNull('users.fcm_token')
            ->whereNotNull('users.lat')
            ->whereNotNull('users.lng')
            ->where('users.last_seen_at', '>=', now()->subMinutes(10))
            ->having('distance', '<', self::RADIUS_KM)
            ->orderBy('distance')
            ->get();

        foreach ($technicians as $technician) {
            $technician->notify(new NewOrderNearby($order, (float) $technician->distance));
        }
    }
}
