<?php

namespace App\Filament\Resources;

use App\Models\ContactMessage;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Actions\Action;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ContactMessageResource extends Resource
{
    protected static ?string $model = ContactMessage::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-envelope';

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_general');
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.contact_messages');
    }

    public static function getModelLabel(): string
    {
        return __('admin.contact_message');
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.contact_messages');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name')->label(__('admin.sender_name'))->disabled(),
            TextInput::make('phone')->label(__('admin.phone'))->disabled(),
            TextInput::make('email')->label(__('admin.email'))->disabled(),
            TextInput::make('subject')->label(__('admin.subject'))->disabled(),
            Textarea::make('message')->label(__('admin.message'))->disabled()->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('name')->label(__('admin.sender_name'))->searchable(),
            TextColumn::make('subject')->label(__('admin.subject'))->searchable(),
            IconColumn::make('is_read')
                ->label(__('admin.is_read'))
                ->boolean()
                ->trueIcon('heroicon-o-check-circle')
                ->falseIcon('heroicon-o-envelope')
                ->trueColor('success')
                ->falseColor('warning'),
            TextColumn::make('created_at')->label(__('admin.created_at'))->dateTime()->sortable(),
        ])
        ->defaultSort('created_at', 'desc')
        ->actions([
            \Filament\Actions\ViewAction::make(),
            Action::make('markAsRead')
                ->label(__('admin.mark_as_read'))
                ->icon('heroicon-m-check')
                ->color('success')
                ->visible(fn (ContactMessage $record) => !$record->is_read)
                ->action(fn (ContactMessage $record) => $record->update(['is_read' => true])),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\ContactMessageResource\Pages\ManageContactMessages::route('/'),
        ];
    }

    public static function canCreate(): bool
    {
        return false; // Read-only
    }
}
