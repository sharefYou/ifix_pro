<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('technician_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('service_id')->constrained()->cascadeOnDelete();
            $table->string('status')->default('pending_tech');
            $table->string('visit_type'); // e.g. normal, urgent
            $table->dateTime('visit_date');
            $table->text('notes')->nullable();
            $table->string('payment_method');
            $table->decimal('total_amount', 10, 2);
            $table->timestamps();
        });

        Schema::create('images', function (Blueprint $table) {
            $table->id();
            $table->string('path');
            $table->morphs('imageable');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('images');
        Schema::dropIfExists('orders');
    }
};
