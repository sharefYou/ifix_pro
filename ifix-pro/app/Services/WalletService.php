<?php

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Exception;
use Illuminate\Support\Facades\DB;

class WalletService
{
    public function holdFunds(User $customer, float $amount): void
    {
        DB::transaction(function () use ($customer, $amount) {
            $wallet = Wallet::where('user_id', $customer->id)->lockForUpdate()->first();

            if (!$wallet) {
                throw new Exception('Wallet not found for customer.');
            }

            $available = (float) ($wallet->available_balance ?? 0);

            if ($available < $amount) {
                throw new Exception('Insufficient funds.');
            }

            $wallet->available_balance = $available - $amount;
            $wallet->held_balance = (float) ($wallet->held_balance ?? 0) + $amount;
            $wallet->save();

            WalletTransaction::create([
                'user_id' => $customer->id,
                'amount' => $amount,
                'type' => 'hold',
                'status' => 'completed',
            ]);
        });
    }

    public function releaseFundsToTechnician(Order $order): void
    {
        DB::transaction(function () use ($order) {
            $amount = (float) $order->total_amount;
            $customerWallet = Wallet::where('user_id', $order->user_id)->lockForUpdate()->first();
            $technicianWallet = Wallet::firstOrCreate(
                ['user_id' => $order->technician_id],
                ['available_balance' => 0, 'held_balance' => 0]
            );

            // Lock technician wallet to prevent race conditions during updates
            $technicianWallet = Wallet::where('id', $technicianWallet->id)->lockForUpdate()->first();

            if (!$customerWallet) {
                throw new Exception('Customer wallet not found.');
            }

            $held = (float) ($customerWallet->held_balance ?? 0);

            if ($held < $amount) {
                throw new Exception('Insufficient held funds.');
            }

            $customerWallet->held_balance = $held - $amount;
            $customerWallet->save();

            WalletTransaction::create([
                'user_id' => $order->user_id,
                'amount' => $amount,
                'type' => 'release',
                'status' => 'completed',
            ]);

            $techAvailable = (float) ($technicianWallet->available_balance ?? 0);
            $technicianWallet->available_balance = $techAvailable + $amount;
            $technicianWallet->save();

            WalletTransaction::create([
                'user_id' => $order->technician_id,
                'amount' => $amount,
                'type' => 'deposit',
                'status' => 'completed',
            ]);
        });
    }

    public function refundCustomer(Order $order): void
    {
        DB::transaction(function () use ($order) {
            $amount = (float) $order->total_amount;
            $wallet = Wallet::where('user_id', $order->user_id)->lockForUpdate()->first();

            if (!$wallet) {
                throw new Exception('Customer wallet not found.');
            }

            $held = (float) ($wallet->held_balance ?? 0);

            if ($held < $amount) {
                throw new Exception('Insufficient held funds to refund.');
            }

            $wallet->held_balance = $held - $amount;
            $wallet->available_balance = (float) ($wallet->available_balance ?? 0) + $amount;
            $wallet->save();

            WalletTransaction::create([
                'user_id' => $order->user_id,
                'amount' => $amount,
                'type' => 'refund',
                'status' => 'completed',
            ]);
        });
    }

    public function refundWithPenalty(Order $order, float $penaltyAmount): void
    {
        DB::transaction(function () use ($order, $penaltyAmount) {
            $amount = (float) $order->total_amount;
            
            $customerWallet = Wallet::where('user_id', $order->user_id)->lockForUpdate()->first();
            $technicianWallet = Wallet::firstOrCreate(
                ['user_id' => $order->technician_id],
                ['available_balance' => 0, 'held_balance' => 0]
            );
            $technicianWallet = Wallet::where('id', $technicianWallet->id)->lockForUpdate()->first();

            if (!$customerWallet) {
                throw new Exception('Customer wallet not found.');
            }

            $held = (float) ($customerWallet->held_balance ?? 0);

            if ($held < $amount) {
                throw new Exception('Insufficient held funds to refund.');
            }

            $refundAmount = $amount - $penaltyAmount;
            
            $customerWallet->held_balance = $held - $amount;
            $customerWallet->available_balance = (float) ($customerWallet->available_balance ?? 0) + $refundAmount;
            $customerWallet->save();

            WalletTransaction::create([
                'user_id' => $order->user_id,
                'amount' => $refundAmount,
                'type' => 'refund',
                'status' => 'completed',
            ]);

            WalletTransaction::create([
                'user_id' => $order->user_id,
                'amount' => $penaltyAmount,
                'type' => 'penalty',
                'status' => 'completed',
            ]);

            $techAvailable = (float) ($technicianWallet->available_balance ?? 0);
            $technicianWallet->available_balance = $techAvailable + $penaltyAmount;
            $technicianWallet->save();

            WalletTransaction::create([
                'user_id' => $order->technician_id,
                'amount' => $penaltyAmount,
                'type' => 'deposit',
                'status' => 'completed',
            ]);
        });
    }

    public function depositFunds(User $user, float $amount): void
    {
        DB::transaction(function () use ($user, $amount) {
            $wallet = Wallet::firstOrCreate(
                ['user_id' => $user->id],
                ['available_balance' => 0, 'held_balance' => 0]
            );

            $wallet = Wallet::where('id', $wallet->id)->lockForUpdate()->first();
            $wallet->available_balance = (float) ($wallet->available_balance ?? 0) + $amount;
            $wallet->save();
        });
    }

    public function requestWithdrawal(User $user, float $amount): void
    {
        DB::transaction(function () use ($user, $amount) {
            $wallet = Wallet::firstOrCreate(
                ['user_id' => $user->id],
                ['available_balance' => 0, 'held_balance' => 0]
            );

            $wallet = Wallet::where('id', $wallet->id)->lockForUpdate()->first();

            if ((float) ($wallet->available_balance ?? 0) < $amount) {
                throw new \Exception(__('messages.insufficient_funds', [], app()->getLocale() ?? 'en'));
            }

            $wallet->available_balance = (float) $wallet->available_balance - $amount;
            $wallet->held_balance = (float) ($wallet->held_balance ?? 0) + $amount;
            $wallet->save();

            WalletTransaction::create([
                'user_id' => $user->id,
                'amount' => $amount,
                'type' => 'withdrawal',
                'status' => 'pending',
            ]);
        });
    }
}
