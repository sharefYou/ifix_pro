<?php

namespace App\Filament\Resources\RechargeCardResource\Pages;

use App\Filament\Resources\RechargeCardResource;
use App\Models\RechargeCard;
use Filament\Actions\Action;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ManageRecords;

class ManageRechargeCards extends ManageRecords
{
    protected static string $resource = RechargeCardResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('generateBatch')
                ->label('توليد بطاقات جديدة')
                ->icon('heroicon-o-plus-circle')
                ->color('primary')
                ->form([
                    Select::make('amount')
                        ->label('فئة البطاقة')
                        ->options([
                            100 => '100',
                            200 => '200',
                            300 => '300',
                            400 => '400',
                            500 => '500',
                            600 => '600',
                            700 => '700',
                            800 => '800',
                            900 => '900',
                            1000 => '1000',
                        ])
                        ->required(),
                    TextInput::make('count')
                        ->label('عدد البطاقات')
                        ->numeric()
                        ->default(10)
                        ->minValue(1)
                        ->maxValue(500)
                        ->required(),
                    DatePicker::make('expires_at')
                        ->label('تاريخ انتهاء الصلاحية')
                        ->default(now()->addMonths(6))
                        ->required(),
                ])
                ->action(function (array $data): void {
                    $count = (int) $data['count'];
                    $amount = (float) $data['amount'];
                    $expiresAt = $data['expires_at'];

                    $cards = [];
                    $now = now();

                    for ($i = 0; $i < $count; $i++) {
                        do {
                            $code = '';
                            for ($j = 0; $j < 14; $j++) {
                                $code .= random_int(0, 9);
                            }
                        } while (RechargeCard::where('code', $code)->exists());

                        $cards[] = [
                            'code' => $code,
                            'amount' => $amount,
                            'expires_at' => $expiresAt,
                            'is_used' => false,
                            'created_at' => $now,
                            'updated_at' => $now,
                        ];
                    }

                    RechargeCard::insert($cards);

                    Notification::make()
                        ->title('تم التوليد بنجاح')
                        ->body("تم توليد $count بطاقة بفئة $amount")
                        ->success()
                        ->send();
                }),
        ];
    }
}
