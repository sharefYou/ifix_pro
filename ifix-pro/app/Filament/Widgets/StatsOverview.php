<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\User;
use App\Models\WalletTransaction;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make(__('admin.total_users'), User::count())
                ->description(__('admin.registered_users'))
                ->descriptionIcon('heroicon-m-users')
                ->color('primary'),
                
            Stat::make(__('admin.total_orders'), Order::count())
                ->description(__('admin.all_time_orders'))
                ->descriptionIcon('heroicon-m-shopping-cart')
                ->color('success'),
                
            Stat::make(__('admin.total_pending_topups'), WalletTransaction::where('status', 'pending')->where('type', 'deposit')->count())
                ->description(__('admin.awaiting_approval'))
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('warning'),
        ];
    }
}
