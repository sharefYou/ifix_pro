<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class OrderAutoAssigned extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        private Order $order,
        private string $recipientType // 'technician' or 'customer'
    ) {}

    public function via(mixed $notifiable): array
    {
        return [FcmChannel::class];
    }

    public function toFcm(mixed $notifiable): array
    {
        if ($this->recipientType === 'technician') {
            return [
                'title' => '🔧 تم تعيينك لطلب جديد',
                'body'  => 'تم تعيينك تلقائياً لطلب صيانة. تحقق من تفاصيل الطلب الآن.',
                'data'  => [
                    'type'     => 'auto_assigned_tech',
                    'order_id' => (string) $this->order->id,
                ],
            ];
        }

        return [
            'title' => '✅ تم العثور على فني لطلبك',
            'body'  => 'تم تعيين فني لطلبك تلقائياً. سيتواصل معك قريباً.',
            'data'  => [
                'type'          => 'auto_assigned_customer',
                'order_id'      => (string) $this->order->id,
                'technician_id' => (string) $this->order->technician_id,
            ],
        ];
    }
}
