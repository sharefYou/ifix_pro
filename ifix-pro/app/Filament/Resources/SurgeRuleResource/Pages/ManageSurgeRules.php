<?php

namespace App\Filament\Resources\SurgeRuleResource\Pages;

use App\Filament\Resources\SurgeRuleResource;
use Filament\Resources\Pages\ManageRecords;

class ManageSurgeRules extends ManageRecords
{
    protected static string $resource = SurgeRuleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            \Filament\Actions\CreateAction::make(),
        ];
    }
}
