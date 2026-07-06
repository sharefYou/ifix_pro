<?php

namespace App\Events;

use App\Models\ChatMessage;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatMessageSent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public ChatMessage $chatMessage)
    {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('order.' . $this->chatMessage->order_id),
        ];
    }

    public function broadcastWith(): array
    {
        return [
            'id' => $this->chatMessage->id,
            'order_id' => $this->chatMessage->order_id,
            'sender_id' => $this->chatMessage->sender_id,
            'message' => $this->chatMessage->message,
            'image_url' => $this->chatMessage->image_url,
            'is_read' => $this->chatMessage->is_read,
            'created_at' => $this->chatMessage->created_at->toIso8601String(),
        ];
    }
}
