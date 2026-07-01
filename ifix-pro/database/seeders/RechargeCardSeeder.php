<?php

namespace Database\Seeders;

use App\Models\RechargeCard;
use Illuminate\Database\Seeder;

class RechargeCardSeeder extends Seeder
{
    public function run(): void
    {
        $cards = [
            ['code' => 'IFIX-100-PRO', 'amount' => 100.00],
            ['code' => 'IFIX-250-VIP', 'amount' => 250.00],
            ['code' => 'IFIX-500-GLD', 'amount' => 500.00],
            ['code' => 'IFIX-050-NEW', 'amount' => 50.00],
            ['code' => 'SUMMER-26-150', 'amount' => 150.00],
        ];

        foreach ($cards as $card) {
            RechargeCard::updateOrCreate([
                'code' => $card['code'],
            ], [
                'amount' => $card['amount'],
                'expires_at' => now()->addYear(),
                'is_used' => false,
            ]);
        }
    }
}
