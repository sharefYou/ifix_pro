<?php

namespace Tests\Feature;

use App\Enums\OrderStatus;
use App\Models\Order;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class Phase2FeaturesTest extends TestCase
{
    use RefreshDatabase;

    public function test_sos_emergency_alert_creation_and_listing(): void
    {
        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now()]);
        $tech = User::factory()->create(['is_technician' => true, 'is_active' => true]);
        $category = ServiceCategory::create(['name' => 'Electrical']);
        $service = Service::create(['name' => ['en' => 'Wiring', 'ar' => 'أسلاك'], 'category_id' => $category->id, 'price' => 150.00]);

        $order = Order::create([
            'user_id'        => $customer->id,
            'technician_id'  => $tech->id,
            'service_id'     => $service->id,
            'status'         => OrderStatus::IN_PROGRESS,
            'visit_type'     => 'normal',
            'visit_date'     => now(),
            'notes'          => 'Check wiring',
            'payment_method' => 'cash',
            'total_amount'   => 150.00,
        ]);

        // 1. Customer triggers SOS alert
        $sosRes = $this->actingAs($customer)->postJson('/api/v1/general/sos/alert', [
            'order_id' => $order->id,
            'lat'      => 24.7136,
            'lng'      => 46.6753,
            'reason'   => 'safety_threat',
        ]);

        $sosRes->assertStatus(201)
               ->assertJsonPath('alert.reason', 'safety_threat')
               ->assertJsonPath('alert.status', 'active');

        $this->assertDatabaseHas('emergency_alerts', [
            'order_id' => $order->id,
            'user_id'  => $customer->id,
            'reason'   => 'safety_threat',
        ]);

        // 2. Tech or Customer lists alerts for order
        $listRes = $this->actingAs($tech)->getJson("/api/v1/general/orders/{$order->id}/sos");
        $listRes->assertStatus(200)
                ->assertJsonCount(1, 'data')
                ->assertJsonPath('data.0.reason', 'safety_threat');
    }

    public function test_smart_cost_calculator_with_urgency_and_vip_discount(): void
    {
        $category = ServiceCategory::create(['name' => 'HVAC']);
        $service = Service::create(['name' => ['en' => 'AC Repair', 'ar' => 'تصليح مكيف'], 'category_id' => $category->id, 'price' => 100.00]);

        $res = $this->postJson('/api/v1/customer/services/calculate-cost', [
            'service_id'       => $service->id,
            'urgency'          => 'urgent', // 1.3 multiplier
            'quantity'         => 2,        // base = 200, subtotal = 260
            'has_vip_discount' => true,     // 15% discount = 39, total = 221
        ]);

        $res->assertStatus(200)
            ->assertJson([
                'service_id'         => $service->id,
                'unit_price'         => 100.00,
                'quantity'           => 2,
                'urgency'            => 'urgent',
                'urgency_multiplier' => 1.3,
                'subtotal'           => 260.00,
                'discount_amount'    => 39.00,
                'estimated_total'    => 221.00,
            ]);
    }
}
