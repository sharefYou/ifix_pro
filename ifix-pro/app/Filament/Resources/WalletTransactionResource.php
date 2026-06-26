<?php

namespace App\Filament\Resources;

use App\Models\WalletTransaction;
use App\Services\WalletService;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class WalletTransactionResource extends Resource
{
    protected static ?string $model = WalletTransaction::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-currency-dollar';
    protected static string|\UnitEnum|null $navigationGroup = 'Financials';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('user_id')
                ->relationship('user', 'name')
                ->required(),
            TextInput::make('amount')->numeric()->required(),
            TextInput::make('type')->required(),
            TextInput::make('status')->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('user.name')->searchable(),
            TextColumn::make('amount')->money(),
            TextColumn::make('type'),
            TextColumn::make('status')
                ->badge()
                ->color(fn (string $state): string => match ($state) {
                    'pending' => 'warning',
                    'completed' => 'success',
                    'rejected' => 'danger',
                    default => 'gray',
                }),
            TextColumn::make('created_at')->dateTime(),
        ])
        ->actions([
            Action::make('Approve')
                ->requiresConfirmation()
                ->color('success')
                ->visible(fn (WalletTransaction $record): bool => $record->status === 'pending')
                ->action(function (WalletTransaction $record) {
                    $walletService = app(WalletService::class);
                    $walletService->depositFunds($record->user, (float) $record->amount);
                    $record->update(['status' => 'completed']);
                }),
            Action::make('Reject')
                ->requiresConfirmation()
                ->color('danger')
                ->visible(fn (WalletTransaction $record): bool => $record->status === 'pending')
                ->action(function (WalletTransaction $record) {
                    $record->update(['status' => 'rejected']);
                }),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\WalletTransactionResource\Pages\ManageWalletTransactions::route('/'),
        ];
    }
}
