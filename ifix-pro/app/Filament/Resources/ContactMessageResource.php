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
    protected static string|\UnitEnum|null $navigationGroup = 'General';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name')->disabled(),
            TextInput::make('phone')->disabled(),
            TextInput::make('email')->disabled(),
            TextInput::make('subject')->disabled(),
            Textarea::make('message')->disabled()->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('name')->searchable(),
            TextColumn::make('subject')->searchable(),
            IconColumn::make('is_read')
                ->boolean()
                ->trueIcon('heroicon-o-check-circle')
                ->falseIcon('heroicon-o-envelope')
                ->trueColor('success')
                ->falseColor('warning'),
            TextColumn::make('created_at')->dateTime()->sortable(),
        ])
        ->defaultSort('created_at', 'desc')
        ->actions([
            \Filament\Actions\ViewAction::make(),
            Action::make('markAsRead')
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
