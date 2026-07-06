<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('audio_memo_path')->nullable()->after('notes');
            $table->string('video_path')->nullable()->after('audio_memo_path');
        });

        Schema::table('custom_requests', function (Blueprint $table) {
            $table->string('audio_memo_path')->nullable()->after('description');
            $table->string('video_path')->nullable()->after('audio_memo_path');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['audio_memo_path', 'video_path']);
        });

        Schema::table('custom_requests', function (Blueprint $table) {
            $table->dropColumn(['audio_memo_path', 'video_path']);
        });
    }
};
