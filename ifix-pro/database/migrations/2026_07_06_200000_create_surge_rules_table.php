<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('surge_rules', function (Blueprint $table) {
            $table->id();
            $table->string('name_ar');
            $table->string('name_en')->nullable();
            $table->decimal('multiplier', 4, 2)->default(1.00); // e.g. 1.25, 1.50
            $table->boolean('is_active')->default(true);
            $table->time('start_time')->nullable();
            $table->time('end_time')->nullable();
            $table->json('days_of_week')->nullable();
            $table->string('condition_type')->default('time_based'); // time_based, manual, weather, emergency
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('surge_rules');
    }
};
