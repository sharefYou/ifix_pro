<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Customer\LoginRequest;
use App\Http\Requests\Api\V1\Customer\RegisterRequest;
use App\Http\Requests\Api\V1\Customer\ResendOtpRequest;
use App\Http\Requests\Api\V1\Customer\VerifyOtpRequest;
use App\Http\Resources\Api\V1\Customer\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $otp = (string) rand(1000, 9999);

        $user = User::create([
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'otp_code' => $otp,
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        return response()->json([
            'message' => __('messages.user_registered'),
            'otp' => $otp,
            'user' => new UserResource($user),
        ]);
    }

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $user = User::where('phone', $request->phone)->first();

        if ($user->otp_code !== $request->otp_code || now()->greaterThan($user->otp_expires_at)) {
            return response()->json([
                'message' => __('messages.invalid_otp'),
            ], 400);
        }

        $user->update([
            'phone_verified_at' => now(),
            'otp_code' => null,
            'otp_expires_at' => null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => __('messages.otp_verified'),
            'token' => $token,
            'user' => new UserResource($user),
        ]);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('phone', $request->phone)->first();

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => __('auth.failed'),
            ], 401);
        }

        if (is_null($user->phone_verified_at)) {
            return response()->json([
                'message' => __('messages.phone_not_verified'),
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => __('messages.logged_in'),
            'token' => $token,
            'user' => new UserResource($user),
        ]);
    }

    public function resendOtp(ResendOtpRequest $request): JsonResponse
    {
        $user = User::where('phone', $request->phone)->first();
        
        $otp = (string) rand(1000, 9999);
        
        $user->update([
            'otp_code' => $otp,
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        return response()->json([
            'message' => __('messages.otp_resent'),
            'otp' => $otp,
        ]);
    }
}
