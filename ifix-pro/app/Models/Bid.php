<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'custom_request_id', 'technician_id', 'price', 'status', 'notes',
    'labor_cost', 'parts_cost', 'counter_price', 'counter_notes',
    'counter_by', 'counter_status'
])]
class Bid extends Model
{
    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'labor_cost' => 'decimal:2',
            'parts_cost' => 'decimal:2',
            'counter_price' => 'decimal:2',
        ];
    }

    public function customRequest(): BelongsTo
    {
        return $this->belongsTo(CustomRequest::class);
    }

    public function technician(): BelongsTo
    {
        return $this->belongsTo(User::class, 'technician_id');
    }
}
