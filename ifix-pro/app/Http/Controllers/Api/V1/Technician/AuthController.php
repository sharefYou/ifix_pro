<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Technician\LoginTechnicianRequest;
use App\Http\Requests\Api\V1\Technician\RegisterTechnicianRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(RegisterTechnicianRequest $request): JsonResponse
    {
        $data = $request->validated();
        
        $documentPath = null;
        if ($request->hasFile('id_document') && $request->file('id_document')->isValid()) {
            $documentPath = $request->file('id_document')->store('technician_documents', 'local');
        }

        $user = User::create([
            'name' => $data['name'],
            'phone' => $data['phone'],
            'password' => Hash::make($data['password']),
            'city' => $data['city'],
            'lat' => $data['lat'],
            'lng' => $data['lng'],
            'is_technician' => true,
            'is_verified' => false,
            'is_online' => false,
            'id_document_path' => $documentPath,
        ]);

        if (!empty($data['service_ids'])) {
            $user->services()->sync($data['service_ids']);
        }

        return response()->json([
            'message' => __('messages.technician_registered', [], app()->getLocale() ?? 'en'),
        ]);
    }

    public function login(LoginTechnicianRequest $request): JsonResponse
    {
        $data = $request->validated();

        $user = User::where('phone', $data['phone'])->where('is_technician', true)->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            if (!$user) {
                Hash::check($data['password'], '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');
            }
            return response()->json([
                'message' => __('messages.invalid_credentials', [], app()->getLocale() ?? 'en'),
            ], 401);
        }

        if (!$user->is_verified) {
            return response()->json([
                'message' => __('messages.account_pending_approval', [], app()->getLocale() ?? 'en'),
            ], 403);
        }

        $token = $user->createToken('technician_token', ['role:technician'])->plainTextToken;

        return response()->json([
            'message' => __('messages.logged_in', [], app()->getLocale() ?? 'en'),
            'token' => $token,
        ]);
    }
}
