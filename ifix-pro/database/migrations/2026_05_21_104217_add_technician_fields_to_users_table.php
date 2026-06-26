<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_technician')->default(false);
            $table->boolean('is_verified')->default(false);
            $table->boolean('is_online')->default(false);
            $table->string('id_document_path')->nullable();
        });

        Schema::create('service_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('service_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            
            $table->unique(['user_id', 'service_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_user');

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['is_technician', 'is_verified', 'is_online', 'id_document_path']);
        });
    }
};
