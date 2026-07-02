<?php

namespace App\Filament\Widgets;

use App\Models\Service;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make(__('admin.total_users'), User::count())
                ->description(__('admin.active_customers_techs'))
                ->descriptionIcon('heroicon-m-user-group')
                ->color('success'),
            
            Stat::make(__('admin.admins'), User::where('is_admin', true)->count())
                ->description(__('admin.system_admins'))
                ->descriptionIcon('heroicon-m-shield-check')
                ->color('warning'),
                
            Stat::make(__('admin.total_services'), Service::count())
                ->description(__('admin.available_services'))
                ->descriptionIcon('heroicon-m-wrench')
                ->color('info'),
        ];
    }
}
