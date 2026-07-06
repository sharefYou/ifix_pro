<?php

namespace App\Http\Requests\Api\V1\Customer;

use Illuminate\Foundation\Http\FormRequest;

class CreateCustomRequestRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'description' => ['required', 'string'],
            'visit_date' => ['required', 'date', 'after:now'],
            'audio_memo_path' => ['nullable', 'string', 'max:1024'],
            'video_path' => ['nullable', 'string', 'max:1024'],
            'images' => ['sometimes', 'array', 'max:5'],
            'images.*' => ['image', 'max:2048'],
        ];
    }
}
