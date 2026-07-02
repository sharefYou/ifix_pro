<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['brand_name', 'primary_color', 'font_family', 'logo_image', 'currency'])]
class ThemeSetting extends Model
{
    //
}
