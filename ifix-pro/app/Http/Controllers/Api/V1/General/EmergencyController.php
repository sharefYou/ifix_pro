<?php

namespace App\Http\Controllers\Api\V1\General;

use App\Http\Controllers\Controller;
use App\Models\EmergencyAlert;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class EmergencyController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'order_id' => 'required|exists:orders,id',
            'lat'      => 'nullable|numeric',
            'lng'      => 'nullable|numeric',
            'reason'   => 'nullable|string|max:255',
        ]);

        $order = Order::findOrFail($data['order_id']);

        if (auth()->id() !== $order->user_id && auth()->id() !== $order->technician_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $alert = EmergencyAlert::create([
            'order_id' => $order->id,
            'user_id'  => auth()->id(),
            'lat'      => $data['lat'] ?? null,
            'lng'      => $data['lng'] ?? null,
            'reason'   => $data['reason'] ?? 'emergency',
            'status'   => 'active',
        ]);

        Log::critical("EMERGENCY SOS ALERT TRIGGERED by User ID: " . auth()->id() . " for Order ID: {$order->id}");

        return response()->json([
            'message' => __('messages.sos_alert_sent', [], app()->getLocale() ?? 'en'),
            'alert'   => $alert->load('user:id,name,phone', 'order:id,status'),
        ], 201);
    }

    public function show(Order $order): JsonResponse
    {
        if (auth()->id() !== $order->user_id && auth()->id() !== $order->technician_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $alerts = EmergencyAlert::where('order_id', $order->id)
                                ->with('user:id,name,phone')
                                ->latest()
                                ->get();

        return response()->json([
            'data' => $alerts,
        ]);
    }
}
