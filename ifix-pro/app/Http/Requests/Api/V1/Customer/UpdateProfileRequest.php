<?php

namespace App\Http\Requests\Api\V1\Customer;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'city' => ['sometimes', 'string', 'max:255'],
            'lat' => ['sometimes', 'numeric'],
            'lng' => ['sometimes', 'numeric'],
            'avatar' => ['sometimes', 'image', 'max:2048'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('name')) {
            $this->merge([
                'name' => strip_tags($this->name),
            ]);
        }
        if ($this->has('city')) {
            $this->merge([
                'city' => strip_tags($this->city),
            ]);
        }
    }
}
