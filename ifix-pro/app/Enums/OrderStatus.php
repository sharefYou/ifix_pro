<?php

namespace App\Enums;

enum OrderStatus: string
{
    case PENDING_TECH = 'pending_tech';
    case PENDING_CUSTOMER = 'pending_customer';
    case ACCEPTED = 'accepted';
    case ON_THE_WAY = 'on_the_way';
    case IN_PROGRESS = 'in_progress';
    case COMPLETED = 'completed';
    case CANCELED = 'canceled';

    public function getLabel(): string
    {
        return match ($this) {
            self::PENDING_TECH => 'Pending Technician',
            self::PENDING_CUSTOMER => 'Pending Customer',
            self::ACCEPTED => 'Accepted',
            self::ON_THE_WAY => 'On The Way',
            self::IN_PROGRESS => 'In Progress',
            self::COMPLETED => 'Completed',
            self::CANCELED => 'Canceled',
        };
    }

    public function getColor(): string
    {
        return match ($this) {
            self::PENDING_TECH, self::PENDING_CUSTOMER => 'warning',
            self::ACCEPTED => 'primary',
            self::ON_THE_WAY, self::IN_PROGRESS => 'info',
            self::COMPLETED => 'success',
            self::CANCELED => 'danger',
        };
    }
}
