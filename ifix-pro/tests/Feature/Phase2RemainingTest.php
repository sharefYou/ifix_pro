<?php

namespace Tests\Feature;

use App\Enums\OrderStatus;
use App\Models\Order;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\SubscriptionPackage;
use App\Models\User;
use App\Models\Wallet;
use App\Services\OrderService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class Phase2RemainingTest extends TestCase
{
    use RefreshDatabase;

    public function test_subscription_packages_and_subscribing_with_wallet(): void
    {
        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now()]);
        Wallet::create(['user_id' => $customer->id, 'available_balance' => 100.00, 'held_balance' => 0.00]);

        $package = SubscriptionPackage::create([
            'name'          => ['en' => 'VIP Monthly', 'ar' => 'VIP شهري'],
            'description'   => ['en' => 'Zero visit fees & 15% off labor', 'ar' => 'بدون رسوم زيارة وخصم 15%'],
            'price'         => 50.00,
            'duration_days' => 30,
            'features'      => ['Zero Visit Fees', '15% Labor Discount'],
            'is_active'     => true,
        ]);

        // 1. List packages
        $listRes = $this->actingAs($customer)->getJson('/api/v1/customer/subscriptions');
        $listRes->assertStatus(200)
                ->assertJsonCount(1, 'data')
                ->assertJsonPath('data.0.price', '50.00');

        // 2. Subscribe to package
        $subRes = $this->actingAs($customer)->postJson("/api/v1/customer/subscriptions/{$package->id}/subscribe");
        $subRes->assertStatus(201);

        $this->assertDatabaseHas('user_subscriptions', [
            'user_id'                 => $customer->id,
            'subscription_package_id' => $package->id,
            'status'                  => 'active',
        ]);

        $this->assertDatabaseHas('wallets', [
            'user_id'           => $customer->id,
            'available_balance' => 50.00,
        ]);

        // 3. Get my subscription
        $myRes = $this->actingAs($customer)->getJson('/api/v1/customer/subscriptions/my-subscription');
        $myRes->assertStatus(200)
              ->assertJsonPath('data.subscription_package_id', $package->id)
              ->assertJsonPath('data.status', 'active');
    }

    public function test_in_app_warranty_tracking_and_claim_flow(): void
    {
        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now()]);
        $tech = User::factory()->create(['is_technician' => true, 'is_active' => true]);
        Wallet::create(['user_id' => $customer->id, 'available_balance' => 0.00, 'held_balance' => 200.00]);
        Wallet::create(['user_id' => $tech->id, 'available_balance' => 0.00, 'held_balance' => 0.00]);
        $category = ServiceCategory::create(['name' => 'Appliances']);
        $service = Service::create(['name' => ['en' => 'Washing Machine Repair', 'ar' => 'تصليح غسالة'], 'category_id' => $category->id, 'price' => 200.00]);

        $order = Order::create([
            'user_id'        => $customer->id,
            'technician_id'  => $tech->id,
            'service_id'     => $service->id,
            'status'         => OrderStatus::IN_PROGRESS,
            'visit_type'     => 'normal',
            'visit_date'     => now(),
            'notes'          => 'Fix drum',
            'payment_method' => 'cash',
            'total_amount'   => 200.00,
        ]);

        // 1. Complete order and verify warranty is activated
        app(OrderService::class)->completeOrder($order);

        $order->refresh();
        $this->assertEquals(OrderStatus::COMPLETED, $order->status);
        $this->assertEquals('active', $order->warranty_status);
        $this->assertNotNull($order->warranty_expires_at);

        // 2. Claim warranty
        $claimRes = $this->actingAs($customer)->postJson("/api/v1/customer/orders/{$order->id}/claim-warranty");
        $claimRes->assertStatus(201)
                 ->assertJsonPath('order.parent_order_id', $order->id)
                 ->assertJsonPath('order.total_amount', '0.00')
                 ->assertJsonPath('order.payment_method', 'warranty');

        $this->assertDatabaseHas('orders', [
            'parent_order_id' => $order->id,
            'user_id'         => $customer->id,
            'technician_id'   => $tech->id,
            'total_amount'    => 0.00,
            'payment_method'  => 'warranty',
        ]);

        $this->assertDatabaseHas('orders', [
            'id'              => $order->id,
            'warranty_status' => 'claimed',
        ]);
    }
}
