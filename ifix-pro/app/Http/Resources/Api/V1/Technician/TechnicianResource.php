<?php

namespace App\Http\Resources\Api\V1\Technician;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\Api\V1\Customer\ServiceResource;

class TechnicianResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'city' => $this->city,
            'lat' => (float) $this->lat,
            'lng' => (float) $this->lng,
            'avatar' => $this->avatar ? url('storage/' . $this->avatar) : null,
            'is_technician' => (bool) $this->is_technician,
            'is_verified' => (bool) $this->is_verified,
            'is_online' => (bool) $this->is_online,
            'services' => ServiceResource::collection($this->whenLoaded('services')),
            'created_at' => $this->created_at,
        ];
    }
}
