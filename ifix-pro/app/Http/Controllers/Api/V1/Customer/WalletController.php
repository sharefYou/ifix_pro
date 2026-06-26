<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Customer\TopUpRequest;
use App\Http\Resources\Api\V1\Customer\WalletResource;
use App\Http\Resources\Api\V1\Customer\WalletTransactionResource;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function balance(): JsonResponse
    {
        $wallet = Wallet::firstOrCreate(
            ['user_id' => auth()->id()],
            ['available_balance' => 0, 'held_balance' => 0]
        );

        return response()->json([
            'data' => new WalletResource($wallet),
        ]);
    }

    public function transactions(): JsonResponse
    {
        $transactions = WalletTransaction::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => WalletTransactionResource::collection($transactions),
        ]);
    }

    public function topUp(TopUpRequest $request): JsonResponse
    {
        // Simple mock of a top-up operation
        $amount = (float) $request->amount;

        DB::transaction(function () use ($amount) {
            $wallet = Wallet::firstOrCreate(
                ['user_id' => auth()->id()],
                ['available_balance' => 0, 'held_balance' => 0]
            );

            $wallet = Wallet::where('id', $wallet->id)->lockForUpdate()->first();
            $wallet->available_balance = (float) ($wallet->available_balance ?? 0) + $amount;
            $wallet->save();

            WalletTransaction::create([
                'user_id' => auth()->id(),
                'amount' => $amount,
                'type' => 'deposit',
                'status' => 'completed',
            ]);
        });

        return response()->json([
            'message' => 'Wallet topped up successfully.',
        ]);
    }
}
