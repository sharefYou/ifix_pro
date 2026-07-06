<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['name', 'description', 'price', 'duration_days', 'features', 'is_active'])]
class SubscriptionPackage extends Model
{
    protected function casts(): array
    {
        return [
            'name'        => 'array',
            'description' => 'array',
            'features'    => 'array',
            'price'       => 'decimal:2',
            'is_active'   => 'boolean',
        ];
    }

    public function userSubscriptions(): HasMany
    {
        return $this->hasMany(UserSubscription::class);
    }
}
