<?php

namespace Database\Seeders;

use App\Models\Image;
use App\Models\Order;
use App\Models\Review;
use App\Models\Service;
use App\Models\User;
use App\Models\WalletTransaction;
use Illuminate\Database\Seeder;

class OrderAndReviewSeeder extends Seeder
{
    public function run(): void
    {
        $customers = User::where('is_technician', false)->where('is_admin', false)->get();
        $technicians = User::where('is_technician', true)->get();
        $services = Service::all();

        if ($customers->isEmpty() || $technicians->isEmpty() || $services->isEmpty()) {
            return;
        }

        $ordersData = [
            [
                'status' => 'completed',
                'visit_type' => 'normal',
                'visit_date' => now()->subDays(10)->setTime(10, 0),
                'notes' => 'يرجى إحضار شاشة أصلية مع أدوات الفك والتركيب.',
                'payment_method' => 'wallet',
                'total_amount' => 150.00,
                'image' => 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?auto=format&fit=crop&w=800&q=80',
                'review' => [
                    'time_rating' => 5,
                    'quality_rating' => 5,
                    'cleanliness_rating' => 5,
                    'avg_rating' => 5.0,
                ],
            ],
            [
                'status' => 'completed',
                'visit_type' => 'urgent',
                'visit_date' => now()->subDays(5)->setTime(14, 30),
                'notes' => 'المكيف السبلت لا يبرد ويصدر صوتاً عالياً من الوحدة الخارجية.',
                'payment_method' => 'cash',
                'total_amount' => 135.00,
                'image' => 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
                'review' => [
                    'time_rating' => 5,
                    'quality_rating' => 4,
                    'cleanliness_rating' => 5,
                    'avg_rating' => 4.67,
                ],
            ],
            [
                'status' => 'completed',
                'visit_type' => 'normal',
                'visit_date' => now()->subDays(3)->setTime(11, 0),
                'notes' => 'تسرب مياه مستمر تحت حوض المطبخ يحتاج صيانة فورية.',
                'payment_method' => 'wallet',
                'total_amount' => 120.00,
                'image' => 'https://images.unsplash.com/photo-1581094288338-2314dddb7ece?auto=format&fit=crop&w=800&q=80',
                'review' => [
                    'time_rating' => 5,
                    'quality_rating' => 5,
                    'cleanliness_rating' => 4,
                    'avg_rating' => 4.67,
                ],
            ],
            [
                'status' => 'in_progress',
                'visit_type' => 'urgent',
                'visit_date' => now()->addHours(2),
                'notes' => 'انقطاع كامل للكهرباء في الصالون والغرفة الرئيسية بسبب التماس.',
                'payment_method' => 'wallet',
                'total_amount' => 90.00,
                'image' => 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=800&q=80',
            ],
            [
                'status' => 'accepted',
                'visit_type' => 'normal',
                'visit_date' => now()->addDay()->setTime(16, 0),
                'notes' => 'ترقية لابتوب ديل بقرص SSD جديد 1 تيرابايت وتنصيب ويندوز.',
                'payment_method' => 'cash',
                'total_amount' => 140.00,
            ],
            [
                'status' => 'pending_tech',
                'visit_type' => 'normal',
                'visit_date' => now()->addDays(2)->setTime(12, 0),
                'notes' => 'تركيب وتأسيس 4 كاميرات مراقبة خارجية للمنزل مع ربطها بالجوال.',
                'payment_method' => 'wallet',
                'total_amount' => 210.00,
            ],
        ];

        foreach ($ordersData as $index => $data) {
            $customer = $customers[$index % $customers->count()];
            $technician = $technicians[$index % $technicians->count()];
            $service = $services[$index % $services->count()];

            $order = Order::create([
                'user_id' => $customer->id,
                'technician_id' => $data['status'] === 'pending_tech' ? null : $technician->id,
                'service_id' => $service->id,
                'status' => $data['status'],
                'visit_type' => $data['visit_type'],
                'visit_date' => $data['visit_date'],
                'notes' => $data['notes'],
                'payment_method' => $data['payment_method'],
                'total_amount' => $data['total_amount'],
            ]);

            if (isset($data['image'])) {
                $order->images()->create([
                    'path' => $data['image'],
                ]);
            }

            if ($data['status'] === 'completed' && isset($data['review'])) {
                Review::create([
                    'order_id' => $order->id,
                    'user_id' => $customer->id,
                    'technician_id' => $technician->id,
                    'time_rating' => $data['review']['time_rating'],
                    'quality_rating' => $data['review']['quality_rating'],
                    'cleanliness_rating' => $data['review']['cleanliness_rating'],
                    'avg_rating' => $data['review']['avg_rating'],
                ]);

                // Create transaction history
                WalletTransaction::create([
                    'user_id' => $customer->id,
                    'amount' => $data['total_amount'],
                    'type' => 'withdrawal',
                    'status' => 'completed',
                ]);

                WalletTransaction::create([
                    'user_id' => $technician->id,
                    'amount' => $data['total_amount'] * 0.85, // after platform commission
                    'type' => 'deposit',
                    'status' => 'completed',
                ]);
            }
        }
    }
}
