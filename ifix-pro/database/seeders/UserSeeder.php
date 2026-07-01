<?php

namespace Database\Seeders;

use App\Models\Service;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make('password123');

        // Technicians list
        $technicians = [
            [
                'name' => 'Eng. Ahmad Al-Mansour | م. أحمد المنصور',
                'email' => 'ahmad.tech@ifixpro.com',
                'phone' => '+963991112233',
                'city' => 'Damascus',
                'lat' => 33.5138,
                'lng' => 36.2765,
                'avatar' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                'balance' => 850.00,
                'category_indices' => [0, 1], // Smart phones & Laptops
            ],
            [
                'name' => 'Khaled Al-Otaibi | خالد العتيبي',
                'email' => 'khaled.ac@ifixpro.com',
                'phone' => '+966501234567',
                'city' => 'Riyadh',
                'lat' => 24.7136,
                'lng' => 46.6753,
                'avatar' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                'balance' => 1420.00,
                'category_indices' => [2, 5], // AC & Home Appliances
            ],
            [
                'name' => 'Eng. Omar Al-Sayed | م. عمر السيد',
                'email' => 'omar.elec@ifixpro.com',
                'phone' => '+971509876543',
                'city' => 'Dubai',
                'lat' => 25.2048,
                'lng' => 55.2708,
                'avatar' => 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
                'balance' => 1100.50,
                'category_indices' => [3, 6], // Electrical & Smart Home CCTV
            ],
            [
                'name' => 'Tariq Al-Homsi | طارق الحمصي',
                'email' => 'tariq.plumb@ifixpro.com',
                'phone' => '+963988776655',
                'city' => 'Damascus',
                'lat' => 33.5150,
                'lng' => 36.2800,
                'avatar' => 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=400&q=80',
                'balance' => 640.00,
                'category_indices' => [4], // Plumbing
            ],
            [
                'name' => 'Youssef Al-Harbi | يوسف الحربي',
                'email' => 'youssef.tech@ifixpro.com',
                'phone' => '+966544332211',
                'city' => 'Jeddah',
                'lat' => 21.5433,
                'lng' => 39.1728,
                'avatar' => 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=400&q=80',
                'balance' => 930.00,
                'category_indices' => [0, 2], // Smart phones & AC
            ],
            [
                'name' => 'Eng. Sami Al-Nasser | م. سامي الناصر',
                'email' => 'sami.smart@ifixpro.com',
                'phone' => '+971523344556',
                'city' => 'Abu Dhabi',
                'lat' => 24.4539,
                'lng' => 54.3773,
                'avatar' => 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=400&q=80',
                'balance' => 1650.00,
                'category_indices' => [1, 6], // Laptops & Smart Home CCTV
            ],
        ];

        $allServices = Service::all();

        foreach ($technicians as $techData) {
            $user = User::updateOrCreate([
                'email' => $techData['email'],
            ], [
                'name' => $techData['name'],
                'phone' => $techData['phone'],
                'password' => $password,
                'city' => $techData['city'],
                'lat' => $techData['lat'],
                'lng' => $techData['lng'],
                'avatar' => $techData['avatar'],
                'phone_verified_at' => now(),
                'is_technician' => true,
                'is_verified' => true,
                'is_online' => true,
                'is_active' => true,
            ]);

            Wallet::updateOrCreate([
                'user_id' => $user->id,
            ], [
                'available_balance' => $techData['balance'],
                'held_balance' => 0.00,
            ]);

            // Assign services to technician
            $servicesToAssign = $allServices->filter(function ($srv) use ($techData) {
                return in_array(($srv->category_id - 1) % 7, $techData['category_indices']);
            })->pluck('id')->toArray();

            if (!empty($servicesToAssign)) {
                $user->services()->syncWithoutDetaching($servicesToAssign);
            }
        }

        // Customers list
        $customers = [
            [
                'name' => 'Faisal Al-Rashed | فيصل الراشد',
                'email' => 'faisal.client@gmail.com',
                'phone' => '+966551122334',
                'city' => 'Riyadh',
                'lat' => 24.7200,
                'lng' => 46.6800,
                'avatar' => 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
                'balance' => 450.00,
            ],
            [
                'name' => 'Nour Al-Huda | نور الهدى',
                'email' => 'nour.client@gmail.com',
                'phone' => '+963933445566',
                'city' => 'Damascus',
                'lat' => 33.5200,
                'lng' => 36.2700,
                'avatar' => 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
                'balance' => 320.00,
            ],
            [
                'name' => 'Rashid Al-Maktoum | راشد المكتوم',
                'email' => 'rashid.client@gmail.com',
                'phone' => '+971567788990',
                'city' => 'Dubai',
                'lat' => 25.2100,
                'lng' => 55.2800,
                'avatar' => 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=400&q=80',
                'balance' => 780.00,
            ],
            [
                'name' => 'Maha Al-Salem | مها السالم',
                'email' => 'maha.client@gmail.com',
                'phone' => '+966588990011',
                'city' => 'Jeddah',
                'lat' => 21.5500,
                'lng' => 39.1800,
                'avatar' => 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80',
                'balance' => 210.00,
            ],
        ];

        foreach ($customers as $custData) {
            $user = User::updateOrCreate([
                'email' => $custData['email'],
            ], [
                'name' => $custData['name'],
                'phone' => $custData['phone'],
                'password' => $password,
                'city' => $custData['city'],
                'lat' => $custData['lat'],
                'lng' => $custData['lng'],
                'avatar' => $custData['avatar'],
                'phone_verified_at' => now(),
                'is_technician' => false,
                'is_verified' => true,
                'is_online' => true,
                'is_active' => true,
            ]);

            Wallet::updateOrCreate([
                'user_id' => $user->id,
            ], [
                'available_balance' => $custData['balance'],
                'held_balance' => 0.00,
            ]);
        }
    }
}
