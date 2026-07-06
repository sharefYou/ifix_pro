<?php

namespace App\Filament\Resources\ServiceCategoryResource\RelationManagers;

use App\Models\Service;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ServicesRelationManager extends RelationManager
{
    protected static string $relationship = 'services';

    public static function getTitle(\Illuminate\Database\Eloquent\Model $ownerRecord, string $pageClass): string
    {
        return __('admin.services');
    }

    public function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name.en')
                ->label(__('admin.name_en'))
                ->required()
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('name', 'en', false)),
            TextInput::make('name.ar')
                ->label(__('admin.name_ar'))
                ->required()
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('name', 'ar', false)),
            Textarea::make('description.en')
                ->label(__('admin.description_en'))
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('description', 'en', false)),
            Textarea::make('description.ar')
                ->label(__('admin.description_ar'))
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('description', 'ar', false)),
            TextInput::make('price')->label(__('admin.price'))->numeric()->required(),
            FileUpload::make('image')
                ->label(__('admin.service_image'))
                ->image()
                ->directory('services')
                ->maxSize(2048)
                ->columnSpanFull(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->columns([
                ImageColumn::make('image')->label(__('admin.image'))->circular(),
                TextColumn::make('name_en')->label(__('admin.name_en'))
                    ->getStateUsing(fn (Service $record): ?string => $record->getTranslation('name', 'en', false)),
                TextColumn::make('name_ar')->label(__('admin.name_ar'))
                    ->getStateUsing(fn (Service $record): ?string => $record->getTranslation('name', 'ar', false)),
                TextColumn::make('price')->label(__('admin.price'))->money(),
            ])
            ->headerActions([
                \Filament\Actions\CreateAction::make()->label(__('admin.add_service')),
            ])
            ->actions([
                \Filament\Actions\EditAction::make(),
                \Filament\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                \Filament\Actions\BulkActionGroup::make([
                    \Filament\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}
