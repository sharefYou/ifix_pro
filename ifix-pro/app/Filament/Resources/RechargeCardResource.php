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
    protected static string|\UnitEnum|null $navigationGroup = 'Financials';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('code')->label('رقم البطاقة')->searchable()->copyable(),
            TextColumn::make('amount')->label('الفئة')->sortable(),
            TextColumn::make('expires_at')->label('تاريخ الانتهاء')->date()->sortable(),
            IconColumn::make('is_used')->label('مستخدمة')->boolean(),
            TextColumn::make('user.name')->label('المستخدم')->placeholder('-'),
            TextColumn::make('used_at')->label('وقت الاستخدام')->dateTime()->placeholder('-'),
            TextColumn::make('created_at')->label('تاريخ التوليد')->dateTime()->sortable(),
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
