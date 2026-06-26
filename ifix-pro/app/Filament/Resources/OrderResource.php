<?php

namespace App\Filament\Resources;

use App\Models\Order;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\DateTimePicker;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class OrderResource extends Resource
{
    protected static ?string $model = Order::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-shopping-cart';
    protected static string|\UnitEnum|null $navigationGroup = 'Orders';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('user_id')
                ->relationship('user', 'name')
                ->required(),
            Select::make('technician_id')
                ->relationship('technician', 'name'),
            Select::make('service_id')
                ->relationship('service', 'name')
                ->required(),
            TextInput::make('status')->required(),
            TextInput::make('visit_type')->required(),
            DateTimePicker::make('visit_date')->required(),
            TextInput::make('payment_method')->required(),
            TextInput::make('total_amount')->numeric()->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('user.name')->searchable(),
            TextColumn::make('technician.name')->searchable(),
            TextColumn::make('status')
                ->badge()
                ->color(fn (string $state): string => match ($state) {
                    'pending_tech' => 'warning',
                    'accepted' => 'info',
                    'on_the_way' => 'primary',
                    'in_progress' => 'primary',
                    'completed' => 'success',
                    'canceled' => 'danger',
                    default => 'gray',
                }),
            TextColumn::make('total_amount')->money(),
            TextColumn::make('visit_date')->dateTime(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\OrderResource\Pages\ManageOrders::route('/'),
        ];
    }
}
