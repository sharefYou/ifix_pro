<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use Filament\Schemas\Components\Tabs\Tab;
use Filament\Resources\Pages\ManageRecords;
use Illuminate\Database\Eloquent\Builder;

class ListUsers extends ManageRecords
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            \Filament\Actions\CreateAction::make()
                ->mutateFormDataUsing(function (array $data): array {
                    $type = $data['account_type'] ?? 'customer';
                    $data['is_admin'] = $type === 'admin';
                    $data['is_technician'] = $type === 'technician';
                    unset($data['account_type']);
                    return $data;
                }),
        ];
    }

    public function getTabs(): array
    {
        return [
            'All' => Tab::make('All'),
            'Admins' => Tab::make('Admins')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_admin', true)),
            'Technicians' => Tab::make('Technicians')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_technician', true)),
            'Customers' => Tab::make('Customers')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_admin', false)->where('is_technician', false)),
        ];
    }
}
