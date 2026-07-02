<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Events\TechnicianLocationUpdated;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TrackingController extends Controller
{
    /**
     * Update technician's general location (background ping, no active order required).
     * Called periodically by the app while the technician is online.
     * Throttle: 30/min (set in routes)
     */
    public function updateLocation(Request $request): JsonResponse
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
        ]);

        auth()->user()->update([
            'lat'          => $request->lat,
            'lng'          => $request->lng,
            'last_seen_at' => now(),
        ]);

        return response()->json([
            'message' => __('messages.location_updated', [], app()->getLocale() ?? 'en'),
        ]);
    }

    /**
     * Broadcast technician's live location for a specific active order.
     * Used by the customer's map to track the technician in real-time.
     * Throttle: 60/min (set in routes)
     */
    public function broadcastLocation(Request $request): JsonResponse
    {
        $request->validate([
            'lat'      => 'required|numeric',
            'lng'      => 'required|numeric',
            'heading'  => 'required|numeric',
            'order_id' => 'required|exists:orders,id',
        ]);

        $order = Order::findOrFail($request->order_id);

        if (auth()->id() !== $order->technician_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Broadcast live location over WebSocket
        broadcast(new TechnicianLocationUpdated(
            $order->id,
            (float) $request->lat,
            (float) $request->lng,
            (float) $request->heading
        ));

        // Keep DB location fresh too
        auth()->user()->update([
            'lat'          => $request->lat,
            'lng'          => $request->lng,
            'last_seen_at' => now(),
        ]);

        return response()->json([
            'message' => __('messages.location_updated', [], app()->getLocale() ?? 'en'),
        ]);
    }
}

