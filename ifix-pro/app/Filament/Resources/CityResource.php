<?php

namespace App\Filament\Resources;

use App\Models\City;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CityResource extends Resource
{
    protected static ?string $model = City::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-building-office-2';
    protected static string|\UnitEnum|null $navigationGroup = 'General';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name.en')->label('Name (EN)')->required()
                ->formatStateUsing(fn (?City $record): ?string => $record?->getTranslation('name', 'en', false)),
            TextInput::make('name.ar')->label('Name (AR)')->required()
                ->formatStateUsing(fn (?City $record): ?string => $record?->getTranslation('name', 'ar', false)),
            Toggle::make('is_active')->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('name_en')->label('Name (EN)')
                ->getStateUsing(fn (City $record): ?string => $record->getTranslation('name', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->en', 'like', "%{$search}%")),
            TextColumn::make('name_ar')->label('Name (AR)')
                ->getStateUsing(fn (City $record): ?string => $record->getTranslation('name', 'ar', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->ar', 'like', "%{$search}%")),
            IconColumn::make('is_active')->boolean(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\CityResource\Pages\ManageCities::route('/'),
        ];
    }
}
