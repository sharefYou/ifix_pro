<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Technician\RequestWithdrawalRequest;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;

class WalletController extends Controller
{
    protected WalletService $walletService;

    public function __construct(WalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    public function balance(): JsonResponse
    {
        $wallet = Wallet::firstOrCreate(
            ['user_id' => auth()->id()],
            ['available_balance' => 0, 'held_balance' => 0]
        );

        return response()->json([
            'available_balance' => (float) $wallet->available_balance,
            'held_balance' => (float) $wallet->held_balance,
        ]);
    }

    public function transactions(): JsonResponse
    {
        $transactions = WalletTransaction::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $transactions,
        ]);
    }

    public function withdraw(RequestWithdrawalRequest $request): JsonResponse
    {
        try {
            $this->walletService->requestWithdrawal(auth()->user(), (float) $request->amount);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }

        return response()->json([
            'message' => __('messages.withdrawal_requested', [], app()->getLocale() ?? 'en'),
        ]);
    }
}
