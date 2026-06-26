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
    protected static string|\UnitEnum|null $navigationGroup = 'Services';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('category_id')
                ->relationship('category', 'name') // Note: this will show JSON in Filament without a custom accessor, but we'll leave it as is unless it's an issue
                ->required(),
            TextInput::make('name.en')
                ->label('Name (EN)')
                ->required()
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('name', 'en', false)),
            TextInput::make('name.ar')
                ->label('Name (AR)')
                ->required()
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('name', 'ar', false)),
            Textarea::make('description.en')
                ->label('Description (EN)')
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('description', 'en', false)),
            Textarea::make('description.ar')
                ->label('Description (AR)')
                ->formatStateUsing(fn (?Service $record): ?string => $record?->getTranslation('description', 'ar', false)),
            TextInput::make('price')->numeric()->required(),
            FileUpload::make('image')
                ->label('Service Image')
                ->image()
                ->directory('services')
                ->maxSize(2048)
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            ImageColumn::make('image')->label('Image')->circular(),
            TextColumn::make('name_en')->label('Name (EN)')
                ->getStateUsing(fn (Service $record): ?string => $record->getTranslation('name', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->en', 'like', "%{$search}%")),
            TextColumn::make('name_ar')->label('Name (AR)')
                ->getStateUsing(fn (Service $record): ?string => $record->getTranslation('name', 'ar', false))
                ->searchable(query: fn ($query, $search) => $query->where('name->ar', 'like', "%{$search}%")),
            TextColumn::make('price')->money(),
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
