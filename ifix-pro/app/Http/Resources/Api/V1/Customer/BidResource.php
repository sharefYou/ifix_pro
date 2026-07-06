<?php

namespace App\Http\Resources\Api\V1\Customer;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BidResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'technician_id' => $this->technician_id,
            'technician_name' => $this->technician->name ?? null,
            'price' => (float) $this->price,
            'labor_cost' => $this->labor_cost !== null ? (float) $this->labor_cost : null,
            'parts_cost' => $this->parts_cost !== null ? (float) $this->parts_cost : null,
            'notes' => $this->notes,
            'counter_price' => $this->counter_price !== null ? (float) $this->counter_price : null,
            'counter_notes' => $this->counter_notes,
            'counter_by' => $this->counter_by,
            'counter_status' => $this->counter_status,
            'status' => $this->status,
            'created_at' => $this->created_at,
        ];
    }
}
