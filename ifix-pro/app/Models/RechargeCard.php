<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RechargeCard extends Model
{
    protected $fillable = [
        'code',
        'amount',
        'expires_at',
        'is_used',
        'used_by_user_id',
        'used_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'float',
            'expires_at' => 'date',
            'is_used' => 'boolean',
            'used_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'used_by_user_id');
    }
}
