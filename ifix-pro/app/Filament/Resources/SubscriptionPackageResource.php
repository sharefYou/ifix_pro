<?php

namespace App\Filament\Resources;

use App\Models\SubscriptionPackage;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SubscriptionPackageResource extends Resource
{
    protected static ?string $model = SubscriptionPackage::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-star';

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_financials');
    }

    public static function getNavigationLabel(): string
    {
        return 'Subscription Packages';
    }

    public static function getModelLabel(): string
    {
        return 'Subscription Package';
    }

    public static function getPluralModelLabel(): string
    {
        return 'Subscription Packages';
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name.en')
                ->label('Name (EN)')
                ->required()
                ->formatStateUsing(fn (?SubscriptionPackage $record): ?string => $record?->getTranslation('name', 'en', false)),
            TextInput::make('name.ar')
                ->label('Name (AR)')
                ->required()
                ->formatStateUsing(fn (?SubscriptionPackage $record): ?string => $record?->getTranslation('name', 'ar', false)),
            Textarea::make('description.en')
                ->label('Description (EN)')
                ->formatStateUsing(fn (?SubscriptionPackage $record): ?string => $record?->getTranslation('description', 'en', false)),
            Textarea::make('description.ar')
                ->label('Description (AR)')
                ->formatStateUsing(fn (?SubscriptionPackage $record): ?string => $record?->getTranslation('description', 'ar', false)),
            TextInput::make('price')
                ->label('Price')
                ->numeric()
                ->required(),
            TextInput::make('duration_days')
                ->label('Duration (Days)')
                ->numeric()
                ->default(30)
                ->required(),
            TagsInput::make('features')
                ->label('Features'),
            Toggle::make('is_active')
                ->label('Active')
                ->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('name_en')->label('Name (EN)')
                ->getStateUsing(fn (SubscriptionPackage $record): ?string => $record->getTranslation('name', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->en', 'like', "%{$search}%")),
            TextColumn::make('name_ar')->label('Name (AR)')
                ->getStateUsing(fn (SubscriptionPackage $record): ?string => $record->getTranslation('name', 'ar', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->ar', 'like', "%{$search}%")),
            TextColumn::make('price')->label('Price')->sortable(),
            TextColumn::make('duration_days')->label('Duration (Days)')->sortable(),
            IconColumn::make('is_active')->label('Active')->boolean(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\SubscriptionPackageResource\Pages\ManageSubscriptionPackages::route('/'),
        ];
    }
}
