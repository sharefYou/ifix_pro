<?php

namespace Tests\Feature;

use App\Models\CustomRequest;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;

class Phase3BiddingTest extends TestCase
{
    use RefreshDatabase;

    public function test_itemized_bidding_counter_offers_and_broadcasting(): void
    {
        Event::fake([
            \App\Events\CustomRequestCreated::class,
            \App\Events\BidUpdated::class,
        ]);

        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now(), 'city' => 'Riyadh']);
        Wallet::create(['user_id' => $customer->id, 'available_balance' => 500.00, 'held_balance' => 0.00]);

        $tech = User::factory()->create([
            'is_active' => true,
            'phone_verified_at' => now(),
            'city' => 'Riyadh',
        ]);

        $category = ServiceCategory::create(['name' => ['en' => 'AC', 'ar' => 'تكييف'], 'is_active' => true]);
        $service = Service::create([
            'category_id' => $category->id,
            'name' => ['en' => 'Repair', 'ar' => 'تصليح'],
            'price' => 100.00,
            'is_active' => true,
        ]);

        // 1. Customer creates Custom Request -> triggers CustomRequestCreated event
        $createRes = $this->actingAs($customer)->postJson('/api/v1/customer/custom-requests', [
            'description' => 'Fix AC compressor',
            'visit_date' => now()->addDays(2)->format('Y-m-d H:i:s'),
        ]);
        $createRes->assertStatus(200);
        $customRequestId = $createRes->json('data.id');

        Event::assertDispatched(\App\Events\CustomRequestCreated::class);

        // 2. Tech submits itemized bid -> triggers BidUpdated event
        $bidRes = $this->actingAs($tech)->postJson("/api/v1/technician/custom-requests/{$customRequestId}/bids", [
            'price' => 250.00,
            'labor_cost' => 100.00,
            'parts_cost' => 150.00,
            'notes' => 'Will replace compressor part and labor included.',
        ]);
        $bidRes->assertStatus(200);
        $bidId = $bidRes->json('data.id');

        Event::assertDispatched(\App\Events\BidUpdated::class);

        $this->assertDatabaseHas('bids', [
            'id' => $bidId,
            'price' => 250.00,
            'labor_cost' => 100.00,
            'parts_cost' => 150.00,
        ]);

        // 3. Customer submits counter-offer
        $counterRes = $this->actingAs($customer)->postJson("/api/v1/customer/custom-requests/{$customRequestId}/bids/{$bidId}/counter", [
            'counter_price' => 200.00,
            'counter_notes' => 'Can we do 200 total?',
        ]);
        $counterRes->assertStatus(200);

        $this->assertDatabaseHas('bids', [
            'id' => $bidId,
            'counter_price' => 200.00,
            'counter_notes' => 'Can we do 200 total?',
            'counter_by' => 'customer',
            'counter_status' => 'pending',
        ]);

        // 4. Tech accepts counter-offer
        $acceptRes = $this->actingAs($tech)->postJson("/api/v1/technician/custom-requests/bids/{$bidId}/accept-counter");
        $acceptRes->assertStatus(200);

        $this->assertDatabaseHas('bids', [
            'id' => $bidId,
            'price' => 200.00,
            'counter_status' => 'accepted',
        ]);

        // 5. Customer accepts final bid -> creates Order & holds wallet balance
        $finalAcceptRes = $this->actingAs($customer)->postJson("/api/v1/customer/custom-requests/{$customRequestId}/bids/{$bidId}/accept", [
            'service_id' => $service->id,
            'visit_type' => 'scheduled',
            'payment_method' => 'wallet',
        ]);
        $finalAcceptRes->assertStatus(200);

        $this->assertDatabaseHas('custom_requests', ['id' => $customRequestId, 'status' => 'accepted']);
        $this->assertDatabaseHas('bids', ['id' => $bidId, 'status' => 'accepted']);
        $this->assertDatabaseHas('orders', ['user_id' => $customer->id, 'technician_id' => $tech->id, 'total_amount' => 200.00]);
        $this->assertDatabaseHas('wallets', ['user_id' => $customer->id, 'available_balance' => 300.00, 'held_balance' => 200.00]);
    }
}
