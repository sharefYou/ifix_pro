<?php

namespace Tests\Feature;

use App\Models\CustomRequest;
use App\Models\Order;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class Phase2VerificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_direct_to_s3_media_upload_for_order_and_custom_request(): void
    {
        Storage::fake('public');

        $customer = User::factory()->create(['is_active' => true, 'phone_verified_at' => now()]);
        \App\Models\Wallet::create(['user_id' => $customer->id, 'available_balance' => 1000.00, 'held_balance' => 0.00]);
        $category = ServiceCategory::create(['name' => 'Plumbing']);
        $service = Service::create(['name' => ['en' => 'Leak Fix', 'ar' => 'إصلاح تسرب'], 'category_id' => $category->id, 'price' => 120.00]);

        // 1. Request presigned URL for voice memo
        $audioPresigned = $this->actingAs($customer)->postJson('/api/v1/general/media/presigned-url', [
            'file_name' => 'voice_memo.aac',
            'file_type' => 'audio/aac',
            'folder'    => 'orders/audio',
        ]);
        $audioPresigned->assertStatus(200)
                       ->assertJsonStructure(['upload_url', 'file_url', 'file_path']);

        // 2. Request presigned URL for video request
        $videoPresigned = $this->actingAs($customer)->postJson('/api/v1/general/media/presigned-url', [
            'file_name' => 'issue_video.mp4',
            'file_type' => 'video/mp4',
            'folder'    => 'orders/video',
        ]);
        $videoPresigned->assertStatus(200)
                       ->assertJsonStructure(['upload_url', 'file_url', 'file_path']);

        // 3. Create Order with audio_memo_path and video_path
        $orderRes = $this->actingAs($customer)->postJson('/api/v1/customer/orders', [
            'service_id'      => $service->id,
            'visit_type'      => 'normal',
            'visit_date'      => now()->addDay()->toIso8601String(),
            'notes'           => 'Pipe leaking under sink',
            'audio_memo_path' => $audioPresigned->json('file_path'),
            'video_path'      => $videoPresigned->json('file_path'),
            'payment_method'  => 'cash',
            'total_amount'    => 120.00,
        ]);

        $orderRes->assertStatus(200)
                 ->assertJsonPath('order.audio_memo_path', $audioPresigned->json('file_path'))
                 ->assertJsonPath('order.video_path', $videoPresigned->json('file_path'));

        $this->assertDatabaseHas('orders', [
            'user_id'         => $customer->id,
            'audio_memo_path' => $audioPresigned->json('file_path'),
            'video_path'      => $videoPresigned->json('file_path'),
        ]);

        // 4. Create Custom Request with audio_memo_path and video_path
        $customRes = $this->actingAs($customer)->postJson('/api/v1/customer/custom-requests', [
            'description'     => 'Need custom kitchen remodeling',
            'visit_date'      => now()->addDays(3)->toIso8601String(),
            'audio_memo_path' => $audioPresigned->json('file_path'),
            'video_path'      => $videoPresigned->json('file_path'),
        ]);

        $customRes->assertStatus(200)
                  ->assertJsonPath('data.description', 'Need custom kitchen remodeling');

        $this->assertDatabaseHas('custom_requests', [
            'user_id'         => $customer->id,
            'audio_memo_path' => $audioPresigned->json('file_path'),
            'video_path'      => $videoPresigned->json('file_path'),
        ]);
    }
}
