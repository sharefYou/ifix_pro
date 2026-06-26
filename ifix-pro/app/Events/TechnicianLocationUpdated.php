<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class TechnicianLocationUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public int $orderId,
        public float $lat,
        public float $lng,
        public float $heading
    ) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('order.' . $this->orderId),
        ];
    }

    public function broadcastWith(): array
    {
        return [
            'lat' => $this->lat,
            'lng' => $this->lng,
            'heading' => $this->heading,
        ];
    }
}
