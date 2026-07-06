<?php

namespace App\Events;

use App\Models\Bid;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class BidUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Bid $bid, public string $targetUserId)
    {
    }

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('user.' . $this->targetUserId),
        ];
    }

    public function broadcastWith(): array
    {
        return [
            'bid_id' => $this->bid->id,
            'custom_request_id' => $this->bid->custom_request_id,
            'technician_id' => $this->bid->technician_id,
            'price' => (float) $this->bid->price,
            'labor_cost' => $this->bid->labor_cost !== null ? (float) $this->bid->labor_cost : null,
            'parts_cost' => $this->bid->parts_cost !== null ? (float) $this->bid->parts_cost : null,
            'counter_price' => $this->bid->counter_price !== null ? (float) $this->bid->counter_price : null,
            'counter_notes' => $this->bid->counter_notes,
            'counter_by' => $this->bid->counter_by,
            'counter_status' => $this->bid->counter_status,
            'status' => $this->bid->status,
        ];
    }
}
