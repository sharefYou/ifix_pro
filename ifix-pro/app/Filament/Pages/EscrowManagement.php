<?php

namespace App\Filament\Pages;

use App\Models\Wallet;
use App\Models\WalletTransaction;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Illuminate\Support\Facades\DB;

class EscrowManagement extends Page
{
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-lock-closed';
    protected static ?int $navigationSort = 30;

    public static function getNavigationGroup(): ?string
    {
        return 'التشغيل والمتابعة الحية';
    }

    public static function getNavigationLabel(): string
    {
        return 'إدارة الضمان المالي (Escrow) 🔒';
    }

    public function getTitle(): string
    {
        return 'إدارة حسابات الضمان المالي والتعليق';
    }

    protected string $view = 'filament.pages.escrow-management';

    public function getTotalEscrowProperty()
    {
        return Wallet::sum('held_balance');
    }

    public function getTotalAvailableProperty()
    {
        return Wallet::sum('balance');
    }

    public function getEscrowWalletsProperty()
    {
        return Wallet::with('user')
            ->where('held_balance', '>', 0)
            ->latest('updated_at')
            ->get();
    }

    public function releaseEscrow(int $walletId): void
    {
        DB::transaction(function () use ($walletId) {
            $wallet = Wallet::lockForUpdate()->find($walletId);
            if ($wallet && $wallet->held_balance > 0) {
                $amount = $wallet->held_balance;
                $wallet->decrement('held_balance', $amount);
                $wallet->increment('balance', $amount);

                WalletTransaction::create([
                    'wallet_id' => $wallet->id,
                    'type' => 'deposit',
                    'amount' => $amount,
                    'reference_type' => 'escrow_release_admin',
                    'reference_id' => auth()->id() ?? 1,
                    'status' => 'completed',
                ]);

                Notification::make()
                    ->title('تم تحرير مبلغ الضمان بنجاح')
                    ->body("تم تحرير {$amount} ريال إلى الرصيد المتاح للمستخدم {$wallet->user->name}")
                    ->success()
                    ->send();
            }
        });
    }

    public function refundEscrow(int $walletId): void
    {
        DB::transaction(function () use ($walletId) {
            $wallet = Wallet::lockForUpdate()->find($walletId);
            if ($wallet && $wallet->held_balance > 0) {
                $amount = $wallet->held_balance;
                $wallet->decrement('held_balance', $amount);
                $wallet->increment('balance', $amount); // Refund back to user's available balance

                WalletTransaction::create([
                    'wallet_id' => $wallet->id,
                    'type' => 'refund',
                    'amount' => $amount,
                    'reference_type' => 'escrow_refund_admin',
                    'reference_id' => auth()->id() ?? 1,
                    'status' => 'completed',
                ]);

                Notification::make()
                    ->title('تم استرداد مبلغ الضمان بنجاح')
                    ->body("تم استرداد {$amount} ريال إلى رصيد العميل {$wallet->user->name}")
                    ->success()
                    ->send();
            }
        });
    }
}
