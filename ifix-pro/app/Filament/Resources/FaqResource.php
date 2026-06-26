<?php

namespace App\Filament\Resources;

use App\Models\Faq;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class FaqResource extends Resource
{
    protected static ?string $model = Faq::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-question-mark-circle';
    protected static string|\UnitEnum|null $navigationGroup = 'General';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('question.en')->label('Question (EN)')->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('question', 'en', false)),
            TextInput::make('question.ar')->label('Question (AR)')->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('question', 'ar', false)),
            RichEditor::make('answer.en')->label('Answer (EN)')->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('answer', 'en', false)),
            RichEditor::make('answer.ar')->label('Answer (AR)')->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('answer', 'ar', false)),
            TextInput::make('sort_order')->numeric()->default(0),
            Toggle::make('is_active')->default(true),
        ])->columns(1);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('question_en')->label('Question (EN)')->limit(50)
                ->getStateUsing(fn (Faq $record): ?string => $record->getTranslation('question', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('question->en', 'like', "%{$search}%")),
            TextColumn::make('sort_order')->sortable(),
            IconColumn::make('is_active')->boolean(),
        ])
        ->reorderable('sort_order')
        ->defaultSort('sort_order')
        ->actions([
            \Filament\Actions\EditAction::make(),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\FaqResource\Pages\ManageFaqs::route('/'),
        ];
    }
}
