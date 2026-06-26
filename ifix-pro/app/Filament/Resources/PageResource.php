<?php

namespace App\Filament\Resources;

use App\Models\Page;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class PageResource extends Resource
{
    protected static ?string $model = Page::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-document-text';
    protected static string|\UnitEnum|null $navigationGroup = 'General';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('slug')->unique(ignoreRecord: true)->required(),
            TextInput::make('title.en')->label('Title (EN)')->required()
                ->formatStateUsing(fn (?Page $record): ?string => $record?->getTranslation('title', 'en', false)),
            TextInput::make('title.ar')->label('Title (AR)')->required()
                ->formatStateUsing(fn (?Page $record): ?string => $record?->getTranslation('title', 'ar', false)),
            RichEditor::make('content.en')->label('Content (EN)')->required()
                ->formatStateUsing(fn (?Page $record): ?string => $record?->getTranslation('content', 'en', false)),
            RichEditor::make('content.ar')->label('Content (AR)')->required()
                ->formatStateUsing(fn (?Page $record): ?string => $record?->getTranslation('content', 'ar', false)),
        ])->columns(1);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('title_en')->label('Title (EN)')
                ->getStateUsing(fn (Page $record): ?string => $record->getTranslation('title', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('title->en', 'like', "%{$search}%")),
            TextColumn::make('slug')->searchable(),
            TextColumn::make('updated_at')->dateTime(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\PageResource\Pages\ManagePages::route('/'),
        ];
    }
}
