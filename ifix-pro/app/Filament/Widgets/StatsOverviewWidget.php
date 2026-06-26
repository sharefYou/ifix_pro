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
            Stat::make('Total Users', User::count())
                ->description('Active customers & technicians')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('success'),
            
            Stat::make('Admins', User::where('is_admin', true)->count())
                ->description('System administrators')
                ->descriptionIcon('heroicon-m-shield-check')
                ->color('warning'),
                
            Stat::make('Total Services', Service::count())
                ->description('Available services')
                ->descriptionIcon('heroicon-m-wrench')
                ->color('info'),
        ];
    }
}
