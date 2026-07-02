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

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_orders');
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.orders');
    }

    public static function getModelLabel(): string
    {
        return __('admin.order');
    }

    public static function getPluralModelLabel(): string
    {
        return __('admin.orders');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('user_id')
                ->label(__('admin.customer'))
                ->relationship('user', 'name')
                ->required(),
            Select::make('technician_id')
                ->label(__('admin.technician'))
                ->relationship('technician', 'name'),
            Select::make('service_id')
                ->label(__('admin.service'))
                ->relationship('service', 'name')
                ->required(),
            TextInput::make('status')->label(__('admin.status'))->required(),
            TextInput::make('visit_type')->label(__('admin.visit_type'))->required(),
            DateTimePicker::make('visit_date')->label(__('admin.visit_date'))->required(),
            TextInput::make('payment_method')->label(__('admin.payment_method'))->required(),
            TextInput::make('total_amount')->label(__('admin.total_amount'))->numeric()->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('user.name')->label(__('admin.customer'))->searchable(),
            TextColumn::make('technician.name')->label(__('admin.technician'))->searchable(),
            TextColumn::make('status')
                ->label(__('admin.status'))
                ->badge()
                ->formatStateUsing(fn (string $state): string => __('admin.status_' . $state))
                ->color(fn (string $state): string => match ($state) {
                    'pending_tech' => 'warning',
                    'accepted' => 'info',
                    'on_the_way' => 'primary',
                    'in_progress' => 'primary',
                    'completed' => 'success',
                    'canceled' => 'danger',
                    default => 'gray',
                }),
            TextColumn::make('total_amount')->label(__('admin.total_amount'))->money(),
            TextColumn::make('visit_date')->label(__('admin.visit_date'))->dateTime(),
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
