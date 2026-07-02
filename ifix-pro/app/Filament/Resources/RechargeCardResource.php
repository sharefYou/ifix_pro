<?php

namespace App\Filament\Resources;

use App\Models\RechargeCard;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class RechargeCardResource extends Resource
{
    protected static ?string $model = RechargeCard::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-credit-card';

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_financials');
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.recharge_cards');
    }

    public static function getModelLabel(): string
    {
        return __('admin.recharge_card');
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.recharge_cards');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('code')->label(__('admin.card_code'))->searchable()->copyable(),
            TextColumn::make('amount')->label(__('admin.card_amount'))->sortable(),
            TextColumn::make('expires_at')->label(__('admin.expires_at'))->date()->sortable(),
            IconColumn::make('is_used')->label(__('admin.is_used'))->boolean(),
            TextColumn::make('user.name')->label(__('admin.used_by'))->placeholder('-'),
            TextColumn::make('used_at')->label(__('admin.used_at'))->dateTime()->placeholder('-'),
            TextColumn::make('created_at')->label(__('admin.created_at'))->dateTime()->sortable(),
        ])
        ->defaultSort('created_at', 'desc')
        ->actions([
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\RechargeCardResource\Pages\ManageRechargeCards::route('/'),
        ];
    }
}
