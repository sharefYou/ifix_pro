<?php

namespace App\Filament\Resources\SubscriptionPackageResource\Pages;

use App\Filament\Resources\SubscriptionPackageResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ManageRecords;

class ManageSubscriptionPackages extends ManageRecords
{
    protected static string $resource = SubscriptionPackageResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
