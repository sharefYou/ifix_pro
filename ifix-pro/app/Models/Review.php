<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['order_id', 'user_id', 'technician_id', 'time_rating', 'quality_rating', 'cleanliness_rating', 'avg_rating'])]
class Review extends Model
{
    protected function casts(): array
    {
        return [
            'time_rating' => 'integer',
            'quality_rating' => 'integer',
            'cleanliness_rating' => 'integer',
            'avg_rating' => 'decimal:2',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function technician(): BelongsTo
    {
        return $this->belongsTo(User::class, 'technician_id');
    }
}
