<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class Phase1VerificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_technician_otp_registration_and_verification(): void
    {
        Storage::fake('local');

        $category = ServiceCategory::create(['name' => 'General']);
        $service = Service::create(['name' => ['en' => 'Fix All', 'ar' => 'إصلاح عام'], 'category_id' => $category->id, 'price' => 100]);

        // 1. Register Technician
        $response = $this->postJson('/api/v1/technician/register', [
            'name'                  => 'John Technician',
            'email'                 => 'john.tech@example.com',
            'phone'                 => '+966500000001',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
            'city'                  => 'Riyadh',
            'lat'                   => 24.7136,
            'lng'                   => 46.6753,
            'id_document'           => UploadedFile::fake()->create('id.pdf', 100),
            'service_ids'           => [$service->id],
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure(['message']);

        $user = User::where('email', 'john.tech@example.com')->first();
        $this->assertNotNull($user);
        $this->assertNull($user->phone_verified_at);
        $this->assertNotNull($user->otp_code);

        $otpCode = $user->otp_code;

        // 2. Verify OTP (returns 403 because account is pending admin approval)
        $verifyRes = $this->postJson('/api/v1/technician/verify-otp', [
            'phone'    => '+966500000001',
            'otp_code' => $otpCode,
        ]);

        $verifyRes->assertStatus(403)
                  ->assertJsonStructure(['message']);

        $user->refresh();
        $this->assertNotNull($user->phone_verified_at);
        $this->assertNull($user->otp_code);

        // Approve technician so login succeeds
        $user->update(['is_verified' => true]);

        // 3. Login with verified technician
        $loginRes = $this->postJson('/api/v1/technician/login', [
            'phone'    => '+966500000001',
            'password' => 'password123',
        ]);

        $loginRes->assertStatus(200)
                 ->assertJsonStructure(['message', 'token']);
    }

    public function test_in_app_secure_chat_and_presigned_url(): void
    {
        Storage::fake('public');

        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now()]);
        $technician = User::factory()->create(['is_active' => true, 'is_technician' => true, 'is_verified' => true, 'phone_verified_at' => now()]);
        
        $category = ServiceCategory::create(['name' => 'Plumbing']);
        $service = Service::create(['name' => ['en' => 'Pipe Fix', 'ar' => 'إصلاح أنبوب'], 'category_id' => $category->id, 'price' => 150.00]);

        $order = Order::create([
            'user_id'       => $customer->id,
            'technician_id' => $technician->id,
            'service_id'    => $service->id,
            'status'        => 'in_progress',
            'visit_type'    => 'standard',
            'visit_date'    => now()->addDay(),
            'payment_method'=> 'cash',
            'total_amount'  => 150.00,
        ]);

        // 1. Customer sends text message
        $sendRes = $this->actingAs($customer)->postJson("/api/v1/general/orders/{$order->id}/chat", [
            'message' => 'Hello Technician, when will you arrive?',
        ]);

        $sendRes->assertStatus(201)
                ->assertJsonPath('data.message', 'Hello Technician, when will you arrive?');

        // 2. Technician retrieves history
        $historyRes = $this->actingAs($technician)->getJson("/api/v1/general/orders/{$order->id}/chat");
        $historyRes->assertStatus(200)
                   ->assertJsonPath('total', 1)
                   ->assertJsonPath('data.0.message', 'Hello Technician, when will you arrive?');

        // 3. Request Presigned URL
        $presignedRes = $this->actingAs($technician)->postJson('/api/v1/general/media/presigned-url', [
            'file_name' => 'leak_photo.jpg',
            'file_type' => 'image/jpeg',
            'folder'    => 'chat_media',
        ]);

        $presignedRes->assertStatus(200)
                     ->assertJsonStructure(['upload_url', 'file_url', 'file_path', 'method']);

        // 4. Test Local Upload Fallback
        $file = UploadedFile::fake()->image('leak_photo.jpg');
        $uploadRes = $this->actingAs($technician)->postJson('/api/v1/general/media/upload-local', [
            'file' => $file,
        ]);

        $uploadRes->assertStatus(200)
                  ->assertJsonStructure(['message', 'file_url', 'file_path']);

        // 5. Send message with image_url
        $imageMsgRes = $this->actingAs($technician)->postJson("/api/v1/general/orders/{$order->id}/chat", [
            'message'   => 'Here is the fixed pipe photo.',
            'image_url' => $uploadRes->json('file_url'),
        ]);

        $imageMsgRes->assertStatus(201)
                    ->assertJsonPath('data.image_url', $uploadRes->json('file_url'));
    }

    public function test_automated_invoicing_engine_simple_invoice(): void
    {
        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now()]);
        $technician = User::factory()->create(['is_active' => true, 'is_technician' => true, 'is_verified' => true, 'phone_verified_at' => now()]);
        $category = ServiceCategory::create(['name' => 'Electrical']);
        $service = Service::create(['name' => ['en' => 'Wiring Fix', 'ar' => 'إصلاح أسلاك'], 'category_id' => $category->id, 'price' => 200.00]);

        $order = Order::create([
            'user_id'       => $customer->id,
            'technician_id' => $technician->id,
            'service_id'    => $service->id,
            'status'        => 'completed',
            'visit_type'    => 'standard',
            'visit_date'    => now(),
            'payment_method'=> 'cash',
            'total_amount'  => 200.00,
        ]);

        // 1. Show invoice JSON
        $jsonRes = $this->actingAs($customer)->getJson("/api/v1/general/orders/{$order->id}/invoice");
        $jsonRes->assertStatus(200)
                ->assertJsonPath('data.invoice.total_amount', '200.00')
                ->assertJsonPath('data.invoice.labor_cost', '140.00')
                ->assertJsonPath('data.invoice.parts_cost', '60.00')
                ->assertJsonPath('data.invoice.discount_amount', '0.00');

        // 2. Download Arabic RTL invoice HTML
        $arRes = $this->actingAs($customer)->withHeaders(['Accept-Language' => 'ar'])
                      ->get("/api/v1/general/orders/{$order->id}/invoice/download");
        $arRes->assertStatus(200)
              ->assertHeader('Content-Type', 'text/html; charset=UTF-8')
              ->assertSee('فاتورة مالية')
              ->assertSee('dir="rtl"', false);

        // 3. Download English LTR invoice HTML
        $enRes = $this->actingAs($technician)->withHeaders(['Accept-Language' => 'en'])
                      ->get("/api/v1/general/orders/{$order->id}/invoice/download");
        $enRes->assertStatus(200)
              ->assertHeader('Content-Type', 'text/html; charset=UTF-8')
              ->assertSee('INVOICE')
              ->assertSee('dir="ltr"', false);
    }

    public function test_live_gps_tracking_broadcast(): void
    {
        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now()]);
        $technician = User::factory()->create(['is_active' => true, 'is_technician' => true, 'is_verified' => true, 'phone_verified_at' => now()]);
        $category = ServiceCategory::create(['name' => 'AC']);
        $service = Service::create(['name' => ['en' => 'AC Repair', 'ar' => 'إصلاح مكيف'], 'category_id' => $category->id, 'price' => 300.00]);

        $order = Order::create([
            'user_id'       => $customer->id,
            'technician_id' => $technician->id,
            'service_id'    => $service->id,
            'status'        => 'on_the_way',
            'visit_type'    => 'standard',
            'visit_date'    => now(),
            'payment_method'=> 'cash',
            'total_amount'  => 300.00,
        ]);

        $res = $this->actingAs($technician)->postJson('/api/v1/technician/tracking/broadcast', [
            'lat'      => 24.7136,
            'lng'      => 46.6753,
            'heading'  => 90.0,
            'order_id' => $order->id,
        ]);

        $res->assertStatus(200)
            ->assertJsonStructure(['message']);

        $technician->refresh();
        $this->assertEquals(24.7136, (float) $technician->lat);
        $this->assertEquals(46.6753, (float) $technician->lng);
        $this->assertNotNull($technician->last_seen_at);
    }
}
