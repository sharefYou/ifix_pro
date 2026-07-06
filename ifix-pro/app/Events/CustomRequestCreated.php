<?php

namespace App\Events;

use App\Models\CustomRequest;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CustomRequestCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public CustomRequest $customRequest)
    {
    }

    public function broadcastOn(): array
    {
        $city = $this->customRequest->user->city ?? 'Riyadh';
        return [
            new PrivateChannel('custom-requests.' . $city),
        ];
    }

    public function broadcastWith(): array
    {
        return [
            'id' => $this->customRequest->id,
            'description' => $this->customRequest->description,
            'visit_date' => $this->customRequest->visit_date,
            'user_name' => $this->customRequest->user->name ?? null,
            'city' => $this->customRequest->user->city ?? null,
            'created_at' => $this->customRequest->created_at,
        ];
    }
}
