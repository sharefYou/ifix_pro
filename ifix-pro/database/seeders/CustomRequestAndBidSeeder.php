<?php

namespace Database\Seeders;

use App\Models\Bid;
use App\Models\CustomRequest;
use App\Models\User;
use Illuminate\Database\Seeder;

class CustomRequestAndBidSeeder extends Seeder
{
    public function run(): void
    {
        $customers = User::where('is_technician', false)->where('is_admin', false)->get();
        $technicians = User::where('is_technician', true)->get();

        if ($customers->isEmpty() || $technicians->isEmpty()) {
            return;
        }

        $requestsData = [
            [
                'description' => 'تأسيس وتمديد شبكة إنترنت Cat6 مع 6 كاميرات مراقبة لفيلا مكونة من طابقين وحديقة خارجية.',
                'visit_date' => now()->addDays(3)->setTime(10, 0),
                'status' => 'pending',
                'image' => 'https://images.unsplash.com/photo-1558002038-1055907df827?auto=format&fit=crop&w=800&q=80',
                'bids' => [
                    [
                        'price' => 450.00,
                        'status' => 'pending',
                        'notes' => 'يشمل السعر الكابلات المقاومة للشمس والحرارة وضبط أجهزة التسجيل.',
                    ],
                    [
                        'price' => 400.00,
                        'status' => 'pending',
                        'notes' => 'تنفيذ احترافي مع ضمان سنة كاملة على التمديدات والبرمجة.',
                    ],
                ]
            ],
            [
                'description' => 'صيانة وتنظيف شامل لـ 5 مكيفات سبلت في المكتب الرئيسي قبل فصل الصيف مع فحص الفريون.',
                'visit_date' => now()->addDays(2)->setTime(13, 30),
                'status' => 'pending',
                'image' => 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
                'bids' => [
                    [
                        'price' => 380.00,
                        'status' => 'pending',
                        'notes' => 'غسيل بالمطهرات والموجات بضغط الماء مع تعبئة النواقص مجاناً.',
                    ],
                ]
            ],
        ];

        foreach ($requestsData as $index => $reqData) {
            $customer = $customers[$index % $customers->count()];

            $customReq = CustomRequest::create([
                'user_id' => $customer->id,
                'description' => $reqData['description'],
                'visit_date' => $reqData['visit_date'],
                'status' => $reqData['status'],
            ]);

            if (isset($reqData['image'])) {
                $customReq->images()->create([
                    'path' => $reqData['image'],
                ]);
            }

            foreach ($reqData['bids'] as $bIndex => $bidData) {
                $technician = $technicians[($index + $bIndex) % $technicians->count()];

                Bid::create([
                    'custom_request_id' => $customReq->id,
                    'technician_id' => $technician->id,
                    'price' => $bidData['price'],
                    'status' => $bidData['status'],
                    'notes' => $bidData['notes'],
                ]);
            }
        }
    }
}
