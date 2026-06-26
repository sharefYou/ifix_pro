<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'sh@v38.dk'],
            [
                'name' => 'Super admin',
                'phone' => '+963996595591',
                'password' => Hash::make('123Sharef32!'),
                'phone_verified_at' => now(),
                'is_verified' => true,
                'is_admin' => true,
            ]
        );
    }
}
