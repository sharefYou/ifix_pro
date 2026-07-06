<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['order_id', 'invoice_number', 'labor_cost', 'parts_cost', 'discount_amount', 'total_amount', 'pdf_path'])]
class Invoice extends Model
{
    protected function casts(): array
    {
        return [
            'labor_cost' => 'decimal:2',
            'parts_cost' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
