<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Technician\UpdateTechnicianProfileRequest;
use App\Http\Resources\Api\V1\Technician\TechnicianResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function show(): JsonResponse
    {
        $user = auth()->user()->load('services');

        return response()->json([
            'message' => __('messages.profile_fetched', [], app()->getLocale() ?? 'en'),
            'data' => new TechnicianResource($user),
        ]);
    }

    public function update(UpdateTechnicianProfileRequest $request): JsonResponse
    {
        $user = auth()->user();
        $data = $request->validated();

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }
            $data['avatar'] = $request->file('avatar')->store('avatars', 'public');
        }

        $user->update($data);

        if (isset($data['service_ids'])) {
            $user->services()->sync($data['service_ids']);
        }

        return response()->json([
            'message' => __('messages.profile_updated', [], app()->getLocale() ?? 'en'),
            'data' => new TechnicianResource($user->load('services')),
        ]);
    }

    public function toggleOnline(): JsonResponse
    {
        $user = auth()->user();
        $user->update(['is_online' => !$user->is_online]);

        return response()->json([
            'message' => __('messages.status_updated', [], app()->getLocale() ?? 'en'),
            'is_online' => $user->is_online,
        ]);
    }
}
