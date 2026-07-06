<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\Order;

Broadcast::channel('order.{orderId}', function ($user, $orderId) {
    $order = Order::find($orderId);
    return $order && ($user->id === $order->user_id || $user->id === $order->technician_id);
});

Broadcast::channel('custom-requests.{city}', function ($user, $city) {
    return $user->city === $city;
});

Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});
