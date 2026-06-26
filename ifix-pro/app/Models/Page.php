<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Spatie\Translatable\HasTranslations;

#[Fillable(['slug', 'title', 'content'])]
class Page extends Model
{
    use HasTranslations;

    public $translatable = ['title', 'content'];
}
