<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'name_ar',
    'name_en',
    'multiplier',
    'is_active',
    'start_time',
    'end_time',
    'days_of_week',
    'condition_type',
])]
class SurgeRule extends Model
{
    protected function casts(): array
    {
        return [
            'multiplier' => 'decimal:2',
            'is_active' => 'boolean',
            'days_of_week' => 'array',
        ];
    }

    public static function getCurrentMultiplier(): float
    {
        $activeRules = self::where('is_active', true)->get();
        if ($activeRules->isEmpty()) {
            return 1.0;
        }

        $maxMultiplier = 1.0;
        $now = now();
        $currentTime = $now->format('H:i:s');
        $currentDay = $now->format('l'); // e.g. Friday

        foreach ($activeRules as $rule) {
            $mult = (float) $rule->multiplier;

            if ($rule->condition_type === 'manual' || $rule->condition_type === 'emergency' || $rule->condition_type === 'weather') {
                if ($mult > $maxMultiplier) {
                    $maxMultiplier = $mult;
                }
                continue;
            }

            if ($rule->condition_type === 'time_based') {
                $dayMatches = empty($rule->days_of_week) || in_array($currentDay, (array) $rule->days_of_week);
                $timeMatches = true;

                if (!empty($rule->start_time) && !empty($rule->end_time)) {
                    if ($rule->start_time <= $rule->end_time) {
                        $timeMatches = ($currentTime >= $rule->start_time && $currentTime <= $rule->end_time);
                    } else {
                        // Overnight rule e.g. 22:00 to 04:00
                        $timeMatches = ($currentTime >= $rule->start_time || $currentTime <= $rule->end_time);
                    }
                }

                if ($dayMatches && $timeMatches && $mult > $maxMultiplier) {
                    $maxMultiplier = $mult;
                }
            }
        }

        return $maxMultiplier;
    }
}
