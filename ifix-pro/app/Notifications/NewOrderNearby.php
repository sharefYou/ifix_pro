<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class NewOrderNearby extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        private Order $order,
        private float $distanceKm
    ) {}

    public function via(mixed $notifiable): array
    {
        return [FcmChannel::class];
    }

    public function toFcm(mixed $notifiable): array
    {
        $serviceName = $this->order->service?->getTranslation('name', app()->getLocale(), false)
            ?? $this->order->service?->name
            ?? 'Unknown Service';

        return [
            'title' => '🔧 طلب صيانة جديد قريب منك',
            'body'  => sprintf(
                'طلب "%s" على بُعد %.1f كم منك. اقبل الآن!',
                $serviceName,
                $this->distanceKm
            ),
            'data' => [
                'type'       => 'new_order_nearby',
                'order_id'   => (string) $this->order->id,
                'service_id' => (string) $this->order->service_id,
                'distance'   => (string) round($this->distanceKm, 1),
            ],
        ];
    }
}
