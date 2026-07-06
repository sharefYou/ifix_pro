<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPackage;
use App\Models\UserSubscription;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class SubscriptionController extends Controller
{
    public function __construct(private WalletService $walletService)
    {
    }

    public function index(): JsonResponse
    {
        $packages = SubscriptionPackage::where('is_active', true)->get();

        return response()->json([
            'data' => $packages,
        ]);
    }

    public function mySubscription(): JsonResponse
    {
        $subscription = UserSubscription::with('package')
            ->where('user_id', auth()->id())
            ->where('status', 'active')
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        return response()->json([
            'data' => $subscription,
        ]);
    }

    public function subscribe(SubscriptionPackage $package): JsonResponse
    {
        if (!$package->is_active) {
            return response()->json(['message' => 'Package is not active.'], 400);
        }

        $user = auth()->user();

        $existing = UserSubscription::where('user_id', $user->id)
            ->where('status', 'active')
            ->where('expires_at', '>', now())
            ->exists();

        if ($existing) {
            return response()->json(['message' => 'You already have an active subscription.'], 400);
        }

        DB::transaction(function () use ($user, $package) {
            $this->walletService->withdrawFunds($user, (float) $package->price);

            UserSubscription::create([
                'user_id'                 => $user->id,
                'subscription_package_id' => $package->id,
                'starts_at'               => now(),
                'expires_at'              => now()->addDays($package->duration_days),
                'status'                  => 'active',
            ]);
        });

        return response()->json([
            'message' => __('messages.subscribed_successfully', [], app()->getLocale() ?? 'en'),
        ], 201);
    }
}
