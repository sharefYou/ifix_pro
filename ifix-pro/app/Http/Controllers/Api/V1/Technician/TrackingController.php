<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Events\TechnicianLocationUpdated;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TrackingController extends Controller
{
    public function updateLocation(Request $request): JsonResponse
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'heading' => 'required|numeric',
            'order_id' => 'required|exists:orders,id',
        ]);

        $order = Order::findOrFail($request->order_id);

        if (auth()->id() !== $order->technician_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Broadcast the event
        broadcast(new TechnicianLocationUpdated(
            $order->id,
            (float) $request->lat,
            (float) $request->lng,
            (float) $request->heading
        ));

        // Update tech's current lat/lng in db
        auth()->user()->update([
            'lat' => $request->lat,
            'lng' => $request->lng,
        ]);

        return response()->json([
            'message' => __('messages.location_updated', [], app()->getLocale() ?? 'en'),
        ]);
    }
}
