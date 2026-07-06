<?php

namespace App\Http\Controllers\Api\V1\General;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Dispute;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DisputeController extends Controller
{
    public function store(Request $request, Order $order): JsonResponse
    {
        $userId = auth()->id();
        if ($order->user_id !== $userId && $order->technician_id !== $userId) {
            return response()->json(['message' => 'Unauthorized to dispute this order.'], 403);
        }

        if ($order->status === OrderStatus::COMPLETED || $order->status === OrderStatus::CANCELED || $order->status === OrderStatus::DISPUTED) {
            return response()->json(['message' => 'Cannot open dispute for an order in this status.'], 400);
        }

        $data = $request->validate([
            'reason' => 'required|string|in:quality_issue,delay,damage,overcharge,other',
            'description' => 'required|string|min:10',
            'evidence_media_paths' => 'nullable|array',
            'evidence_media_paths.*' => 'string',
        ]);

        $dispute = Dispute::create([
            'order_id' => $order->id,
            'opened_by_user_id' => $userId,
            'reason' => $data['reason'],
            'description' => $data['description'],
            'evidence_media_paths' => $data['evidence_media_paths'] ?? [],
            'status' => 'open',
        ]);

        // Freeze escrow funds by updating order status to DISPUTED
        $order->update(['status' => OrderStatus::DISPUTED]);

        return response()->json([
            'message' => 'تم فتح نزاع رسمي وتجميد الرصيد المعلق في الضمان لحين التحكيم من قبل الإدارة.',
            'dispute' => $dispute,
        ], 201);
    }

    public function show(Order $order): JsonResponse
    {
        $userId = auth()->id();
        if ($order->user_id !== $userId && $order->technician_id !== $userId) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $dispute = $order->dispute()->with(['openedBy', 'resolvedBy'])->first();

        return response()->json([
            'data' => $dispute,
        ]);
    }
}
