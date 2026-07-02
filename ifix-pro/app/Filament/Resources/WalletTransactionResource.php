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

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_financials');
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.wallet_transactions');
    }

    public static function getModelLabel(): string
    {
        return __('admin.wallet_transaction');
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.wallet_transactions');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('user_id')
                ->label(__('admin.used_by'))
                ->relationship('user', 'name')
                ->required(),
            TextInput::make('amount')->label(__('admin.amount'))->numeric()->required(),
            TextInput::make('type')->label(__('admin.type'))->required(),
            TextInput::make('status')->label(__('admin.status'))->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('user.name')->label(__('admin.used_by'))->searchable(),
            TextColumn::make('amount')->label(__('admin.amount'))->money(),
            TextColumn::make('type')->label(__('admin.type')),
            TextColumn::make('status')
                ->label(__('admin.status'))
                ->badge()
                ->formatStateUsing(fn (string $state): string => __('admin.status_' . $state))
                ->color(fn (string $state): string => match ($state) {
                    'pending' => 'warning',
                    'completed' => 'success',
                    'rejected' => 'danger',
                    default => 'gray',
                }),
            TextColumn::make('created_at')->label(__('admin.created_at'))->dateTime(),
        ])
        ->actions([
            Action::make('Approve')
                ->label(__('admin.approve'))
                ->requiresConfirmation()
                ->color('success')
                ->visible(fn (WalletTransaction $record): bool => $record->status === 'pending')
                ->action(function (WalletTransaction $record) {
                    $walletService = app(WalletService::class);
                    $walletService->depositFunds($record->user, (float) $record->amount);
                    $record->update(['status' => 'completed']);
                }),
            Action::make('Reject')
                ->label(__('admin.reject'))
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
