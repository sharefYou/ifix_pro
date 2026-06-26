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
            'status' => $this->status,
            'created_at' => $this->created_at,
        ];
    }
}
