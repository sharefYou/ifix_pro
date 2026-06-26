<?php

namespace App\Http\Resources\Api\V1\Customer;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'email' => $this->email,
            'city' => $this->city,
            'lat' => $this->lat,
            'lng' => $this->lng,
            'avatar' => $this->avatar ? url('storage/' . $this->avatar) : null,
            'phone_verified_at' => $this->phone_verified_at,
            'created_at' => $this->created_at,
        ];
    }
}
