<?php

namespace App\Filament\Resources;

use App\Models\ServiceCategory;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ServiceCategoryResource extends Resource
{
    protected static ?string $model = ServiceCategory::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-tag';
    protected static string|\UnitEnum|null $navigationGroup = 'Services';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name.en')
                ->label('Name (EN)')
                ->required()
                ->formatStateUsing(fn (?ServiceCategory $record): ?string => $record?->getTranslation('name', 'en', false)),
            TextInput::make('name.ar')
                ->label('Name (AR)')
                ->required()
                ->formatStateUsing(fn (?ServiceCategory $record): ?string => $record?->getTranslation('name', 'ar', false)),
            Textarea::make('description.en')
                ->label('Description (EN)')
                ->formatStateUsing(fn (?ServiceCategory $record): ?string => $record?->getTranslation('description', 'en', false)),
            Textarea::make('description.ar')
                ->label('Description (AR)')
                ->formatStateUsing(fn (?ServiceCategory $record): ?string => $record?->getTranslation('description', 'ar', false)),
            FileUpload::make('icon')
                ->label('Category Icon')
                ->image()
                ->directory('service_categories')
                ->maxSize(2048)
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            ImageColumn::make('icon')->label('Icon')->circular(),
            TextColumn::make('name_en')->label('Name (EN)')
                ->getStateUsing(fn (ServiceCategory $record): ?string => $record->getTranslation('name', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->en', 'like', "%{$search}%")),
            TextColumn::make('name_ar')->label('Name (AR)')
                ->getStateUsing(fn (ServiceCategory $record): ?string => $record->getTranslation('name', 'ar', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->ar', 'like', "%{$search}%")),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\ServiceCategoryResource\Pages\ManageServiceCategories::route('/'),
        ];
    }
}
