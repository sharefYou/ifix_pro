<?php

namespace App\Filament\Resources;

use App\Models\User;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class UserResource extends Resource
{
    protected static ?string $model = User::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-users';
    protected static string|\UnitEnum|null $navigationGroup = 'User Management';
    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            \Filament\Forms\Components\FileUpload::make('avatar')
                ->avatar()
                ->directory('avatars')
                ->maxSize(2048)
                ->columnSpanFull(),
            TextInput::make('name')->required(),
            TextInput::make('phone')->required()->unique(ignoreRecord: true),
            TextInput::make('email')->email()->unique(ignoreRecord: true),
            TextInput::make('password')->password()->dehydrated(fn ($state) => filled($state))->required(fn (string $context): bool => $context === 'create'),
            DateTimePicker::make('phone_verified_at'),
            Select::make('account_type')
                ->options([
                    'admin' => 'Admin',
                    'technician' => 'Technician',
                    'customer' => 'Customer',
                ])
                ->dehydrated(true)
                ->afterStateHydrated(function ($component, ?User $record) {
                    if (!$record) return;
                    if ($record->is_admin) $component->state('admin');
                    elseif ($record->is_technician) $component->state('technician');
                    else $component->state('customer');
                })
                ->required(),
            Toggle::make('is_active')->label('Active')->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            \Filament\Tables\Columns\ImageColumn::make('avatar')->circular(),
            TextColumn::make('name')->searchable(),
            TextColumn::make('phone')->searchable(),
            TextColumn::make('email')->searchable(),
            ToggleColumn::make('is_active')->label('Active/Suspended'),
            TextColumn::make('created_at')->dateTime(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make()
                ->mutateFormDataUsing(function (array $data): array {
                    $type = $data['account_type'] ?? 'customer';
                    $data['is_admin'] = $type === 'admin';
                    $data['is_technician'] = $type === 'technician';
                    unset($data['account_type']);
                    return $data;
                }),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\UserResource\Pages\ListUsers::route('/'),
        ];
    }
}
