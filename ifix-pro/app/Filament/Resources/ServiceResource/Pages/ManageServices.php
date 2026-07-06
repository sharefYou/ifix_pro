<?php

namespace App\Filament\Resources\ServiceResource\Pages;

use App\Filament\Resources\ServiceResource;
use App\Models\ServiceCategory;
use Filament\Resources\Components\Tab;
use Filament\Resources\Pages\ManageRecords;

class ManageServices extends ManageRecords
{
    protected static string $resource = ServiceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            \Filament\Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        $tabs = [
            'all' => Tab::make(__('admin.all')),
        ];

        foreach (ServiceCategory::all() as $category) {
            $name = $category->getTranslation('name', app()->getLocale(), false) ?: (is_string($category->name) ? $category->name : 'قسم');
            $tabs["category_{$category->id}"] = Tab::make($name)
                ->modifyQueryUsing(fn ($query) => $query->where('category_id', $category->id));
        }

        return $tabs;
    }
}
