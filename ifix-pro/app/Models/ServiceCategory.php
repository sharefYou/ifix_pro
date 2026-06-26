<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\Translatable\HasTranslations;

#[Fillable(['name', 'description', 'icon'])]
class ServiceCategory extends Model
{
    use HasTranslations;

    public array $translatable = ['name', 'description'];

    public function services(): HasMany
    {
        return $this->hasMany(Service::class, 'category_id');
    }
}
