<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FcmNotification;

class FcmChannel
{
    public function __construct(private Messaging $messaging)
    {
    }

    public function send(mixed $notifiable, Notification $notification): void
    {
        $token = $notifiable->fcm_token ?? null;

        if (empty($token)) {
            return;
        }

        if (! method_exists($notification, 'toFcm')) {
            return;
        }

        $payload = $notification->toFcm($notifiable);

        $message = CloudMessage::withTarget('token', $token)
            ->withNotification(
                FcmNotification::create($payload['title'], $payload['body'])
            )
            ->withData($payload['data'] ?? []);

        try {
            $this->messaging->send($message);
        } catch (\Throwable) {
            // Silently fail — invalid/expired tokens should not crash the app
        }
    }
}
