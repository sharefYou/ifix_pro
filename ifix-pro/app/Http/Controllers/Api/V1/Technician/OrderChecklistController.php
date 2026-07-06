<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderChecklist;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderChecklistController extends Controller
{
    public function show(Order $order): JsonResponse
    {
        if ($order->technician_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $checklist = $order->checklist ?? OrderChecklist::create([
            'order_id' => $order->id,
        ]);

        return response()->json([
            'data' => $checklist,
        ]);
    }

    public function store(Request $request, Order $order): JsonResponse
    {
        if ($order->technician_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $data = $request->validate([
            'safety_checked' => 'nullable|boolean',
            'power_disconnected' => 'nullable|boolean',
            'work_area_clean' => 'nullable|boolean',
            'system_tested' => 'nullable|boolean',
            'before_photo_path' => 'nullable|string',
            'after_photo_path' => 'nullable|string',
            'customer_signature_path' => 'nullable|string',
            'customer_notes' => 'nullable|string',
        ]);

        $checklist = $order->checklist ?? new OrderChecklist(['order_id' => $order->id]);
        $checklist->fill($data);

        if (!empty($data['system_tested']) || !empty($data['customer_signature_path'])) {
            $checklist->completed_at = now();
        }

        $checklist->save();

        return response()->json([
            'message' => 'تم حفظ قائمة الفحص بنجاح',
            'data' => $checklist,
        ]);
    }
}
