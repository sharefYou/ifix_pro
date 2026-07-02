<?php

namespace App\Filament\Resources;

use App\Models\Service;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ServiceResource extends Resource
{
    protected static ?string $model = Service::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-wrench';

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_services');
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.services');
    }

    public static function getModelLabel(): string
    {
        return __('admin.service_item');
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.services');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('category_id')
                ->label(__('admin.category'))
                ->relationship('category', 'name')
                ->required(),
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

    public static function table(Table $table): Table
    {
        return $table->columns([
            ImageColumn::make('image')->label(__('admin.image'))->circular(),
            TextColumn::make('name_en')->label(__('admin.name_en'))
                ->getStateUsing(fn (Service $record): ?string => $record->getTranslation('name', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->en', 'like', "%{$search}%")),
            TextColumn::make('name_ar')->label(__('admin.name_ar'))
                ->getStateUsing(fn (Service $record): ?string => $record->getTranslation('name', 'ar', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->ar', 'like', "%{$search}%")),
            TextColumn::make('price')->label(__('admin.price'))->money(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\ServiceResource\Pages\ManageServices::route('/'),
        ];
    }
}
