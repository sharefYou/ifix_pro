<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class Phase3AnalyticsTest extends TestCase
{
    use RefreshDatabase;

    public function test_technician_analytics_endpoint(): void
    {
        $tech = User::factory()->create([
            'is_active' => true,
            'phone_verified_at' => now(),
            'is_technician' => true,
        ]);

        // 1. Test fallback mock data when technician has 0 completed jobs
        $resMock = $this->actingAs($tech)->getJson('/api/v1/technician/analytics');
        $resMock->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('is_mock', true)
            ->assertJsonPath('data.summary.completed_jobs', 24);

        // 2. Create real completed orders
        $customer = User::factory()->create(['is_active' => true]);
        Wallet::create(['user_id' => $customer->id, 'available_balance' => 1000.00, 'held_balance' => 0.00]);
        Wallet::create(['user_id' => $tech->id, 'available_balance' => 0.00, 'held_balance' => 0.00]);

        $category = ServiceCategory::create(['name' => ['en' => 'Plumbing', 'ar' => 'سباكة'], 'is_active' => true]);
        $service = Service::create([
            'category_id' => $category->id,
            'name' => ['en' => 'Leak Repair', 'ar' => 'تصليح تسرب'],
            'price' => 250.00,
            'is_active' => true,
        ]);

        Order::create([
            'user_id' => $customer->id,
            'technician_id' => $tech->id,
            'service_id' => $service->id,
            'status' => 'completed',
            'total_amount' => 250.00,
            'visit_date' => now()->format('Y-m-d H:i:s'),
            'visit_type' => 'home',
            'payment_method' => 'wallet',
        ]);

        Order::create([
            'user_id' => $customer->id,
            'technician_id' => $tech->id,
            'service_id' => $service->id,
            'status' => 'completed',
            'total_amount' => 350.00,
            'visit_date' => now()->format('Y-m-d H:i:s'),
            'visit_type' => 'home',
            'payment_method' => 'wallet',
        ]);

        // 3. Test real analytics data
        $resReal = $this->actingAs($tech)->getJson('/api/v1/technician/analytics');
        $resReal->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('is_mock', false)
            ->assertJsonPath('data.summary.completed_jobs', 2)
            ->assertJsonPath('data.summary.total_earnings', 600)
            ->assertJsonPath('data.category_breakdown.0.count', 2);
    }
}
