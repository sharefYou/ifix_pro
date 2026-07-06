<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Technician\LoginTechnicianRequest;
use App\Http\Requests\Api\V1\Technician\RegisterTechnicianRequest;
use App\Http\Requests\Api\V1\Technician\ResendTechnicianOtpRequest;
use App\Http\Requests\Api\V1\Technician\VerifyTechnicianOtpRequest;
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

        $otp = (string) random_int(1000, 9999);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'] ?? $data['phone'] . '@technician.ifix',
            'phone' => $data['phone'],
            'password' => Hash::make($data['password']),
            'city' => $data['city'],
            'lat' => $data['lat'],
            'lng' => $data['lng'],
            'is_technician' => true,
            'is_verified' => false,
            'is_online' => false,
            'id_document_path' => $documentPath,
            'otp_code' => $otp,
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        if (!empty($data['service_ids'])) {
            $user->services()->sync($data['service_ids']);
        }

        $payload = [
            'message' => __('messages.technician_registered', [], app()->getLocale() ?? 'en'),
        ];

        if (app()->environment('local', 'testing')) {
            $payload['otp'] = $otp;
        }

        return response()->json($payload);
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

        if (is_null($user->phone_verified_at)) {
            return response()->json([
                'message' => __('messages.phone_not_verified', [], app()->getLocale() ?? 'en'),
            ], 403);
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

    public function verifyOtp(VerifyTechnicianOtpRequest $request): JsonResponse
    {
        $user = User::where('phone', $request->phone)->where('is_technician', true)->first();

        if (!$user || !hash_equals((string) $user->otp_code, (string) $request->otp_code) || now()->greaterThan($user->otp_expires_at)) {
            return response()->json([
                'message' => __('messages.invalid_otp', [], app()->getLocale() ?? 'en'),
            ], 400);
        }

        $user->update([
            'phone_verified_at' => now(),
            'otp_code' => null,
            'otp_expires_at' => null,
        ]);

        if (!$user->is_verified) {
            return response()->json([
                'message' => __('messages.account_pending_approval', [], app()->getLocale() ?? 'en'),
            ], 403);
        }

        $token = $user->createToken('technician_token', ['role:technician'])->plainTextToken;

        return response()->json([
            'message' => __('messages.otp_verified', [], app()->getLocale() ?? 'en'),
            'token' => $token,
        ]);
    }

    public function resendOtp(ResendTechnicianOtpRequest $request): JsonResponse
    {
        $user = User::where('phone', $request->phone)->where('is_technician', true)->first();

        if (!$user) {
            return response()->json([
                'message' => __('messages.user_not_found', [], app()->getLocale() ?? 'en'),
            ], 404);
        }

        if (!is_null($user->phone_verified_at)) {
            return response()->json([
                'message' => __('messages.already_verified', [], app()->getLocale() ?? 'en'),
            ], 400);
        }

        $otp = (string) random_int(1000, 9999);
        $user->update([
            'otp_code' => $otp,
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        $payload = [
            'message' => __('messages.otp_sent', [], app()->getLocale() ?? 'en'),
        ];

        if (app()->environment('local', 'testing')) {
            $payload['otp'] = $otp;
        }

        return response()->json($payload);
    }
}

