<?php

namespace Database\Seeders;

use App\Models\ThemeSetting;
use Illuminate\Database\Seeder;

class ThemeSettingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        ThemeSetting::updateOrCreate(
            ['brand_name' => 'iFix Pro'],
            [
                'primary_color' => '#f59e0b',
                'font_family' => 'Cairo',
                'logo_image' => 'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=400&q=80',
            ]
        );
    }
}
