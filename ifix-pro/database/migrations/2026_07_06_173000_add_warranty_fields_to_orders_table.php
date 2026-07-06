<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dateTime('warranty_expires_at')->nullable()->after('total_amount');
            $table->string('warranty_status')->nullable()->after('warranty_expires_at');
            $table->foreignId('parent_order_id')->nullable()->after('id')->constrained('orders')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['parent_order_id']);
            $table->dropColumn(['warranty_expires_at', 'warranty_status', 'parent_order_id']);
        });
    }
};
