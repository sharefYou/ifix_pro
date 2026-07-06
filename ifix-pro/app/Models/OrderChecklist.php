<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'order_id',
    'safety_checked',
    'power_disconnected',
    'work_area_clean',
    'system_tested',
    'before_photo_path',
    'after_photo_path',
    'customer_signature_path',
    'customer_notes',
    'completed_at',
])]
class OrderChecklist extends Model
{
    protected function casts(): array
    {
        return [
            'safety_checked' => 'boolean',
            'power_disconnected' => 'boolean',
            'work_area_clean' => 'boolean',
            'system_tested' => 'boolean',
            'completed_at' => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
