<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('disputes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->onDelete('cascade');
            $table->foreignId('opened_by_user_id')->constrained('users')->onDelete('cascade');
            $table->string('reason'); // quality_issue, delay, damage, overcharge, other
            $table->text('description');
            $table->json('evidence_media_paths')->nullable(); // array of S3 urls
            $table->string('status')->default('open'); // open, under_review, resolved_refund_customer, resolved_release_tech, resolved_split
            $table->text('admin_notes')->nullable();
            $table->foreignId('resolved_by_admin_id')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('disputes');
    }
};
