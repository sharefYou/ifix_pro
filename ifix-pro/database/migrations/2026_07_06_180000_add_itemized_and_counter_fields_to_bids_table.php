<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bids', function (Blueprint $table) {
            $table->decimal('labor_cost', 10, 2)->nullable()->after('price');
            $table->decimal('parts_cost', 10, 2)->nullable()->after('labor_cost');
            $table->decimal('counter_price', 10, 2)->nullable()->after('parts_cost');
            $table->text('counter_notes')->nullable()->after('counter_price');
            $table->string('counter_by')->nullable()->after('counter_notes'); // 'customer' or 'technician'
            $table->string('counter_status')->nullable()->after('counter_by'); // 'pending', 'accepted', 'rejected'
        });
    }

    public function down(): void
    {
        Schema::table('bids', function (Blueprint $table) {
            $table->dropColumn([
                'labor_cost',
                'parts_cost',
                'counter_price',
                'counter_notes',
                'counter_by',
                'counter_status',
            ]);
        });
    }
};
