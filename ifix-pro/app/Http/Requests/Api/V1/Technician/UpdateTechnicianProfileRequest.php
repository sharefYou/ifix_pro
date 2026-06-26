<?php

namespace App\Http\Requests\Api\V1\Technician;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTechnicianProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'city' => ['sometimes', 'string'],
            'avatar' => ['sometimes', 'image', 'max:2048'],
            'service_ids' => ['sometimes', 'array', 'min:1'],
            'service_ids.*' => ['exists:services,id'],
        ];
    }
}
