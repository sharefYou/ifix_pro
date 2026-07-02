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

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_general');
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.faqs');
    }

    public static function getModelLabel(): string
    {
        return __('admin.faq');
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.faqs');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('question.en')->label(__('admin.question_en'))->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('question', 'en', false)),
            TextInput::make('question.ar')->label(__('admin.question_ar'))->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('question', 'ar', false)),
            RichEditor::make('answer.en')->label(__('admin.answer_en'))->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('answer', 'en', false)),
            RichEditor::make('answer.ar')->label(__('admin.answer_ar'))->required()
                ->formatStateUsing(fn (?Faq $record): ?string => $record?->getTranslation('answer', 'ar', false)),
            TextInput::make('sort_order')->label(__('admin.sort_order'))->numeric()->default(0),
            Toggle::make('is_active')->label(__('admin.is_active'))->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('question_en')->label(__('admin.question_en'))->limit(50)
                ->getStateUsing(fn (Faq $record): ?string => $record->getTranslation('question', 'en', false))
                ->searchable(query: fn ($query, $search) => $query->where('question->en', 'like', "%{$search}%")),
            TextColumn::make('sort_order')->label(__('admin.sort_order'))->sortable(),
            IconColumn::make('is_active')->label(__('admin.is_active'))->boolean(),
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
