<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            AdminSeeder::class,
            ThemeSettingSeeder::class,
            GeneralDataSeeder::class,
            ServiceSeeder::class,
            UserSeeder::class,
            OrderAndReviewSeeder::class,
            CustomRequestAndBidSeeder::class,
            RechargeCardSeeder::class,
        ]);
    }
}
