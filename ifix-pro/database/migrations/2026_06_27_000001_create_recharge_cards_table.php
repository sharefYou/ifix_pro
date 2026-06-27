<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recharge_cards', function (Blueprint $table) {
            $table->id();
            $table->string('code', 14)->unique();
            $table->decimal('amount', 10, 2);
            $table->date('expires_at');
            $table->boolean('is_used')->default(false);
            $table->foreignId('used_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('used_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recharge_cards');
    }
};
