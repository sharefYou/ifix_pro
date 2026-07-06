<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function available(): JsonResponse
    {
        $tech = auth()->user();
        $serviceIds = $tech->services()->pluck('services.id');

        // Join users to get customer lat/lng for Haversine calculation
        $orders = Order::select('orders.*')
            ->join('users', 'orders.user_id', '=', 'users.id')
            ->where('orders.status', OrderStatus::PENDING_TECH->value)
            ->whereIn('orders.service_id', $serviceIds)
            ->whereNotNull('users.lat')
            ->whereNotNull('users.lng')
            ->selectRaw(
                "( 6371 * acos( cos( radians(?) ) *
                cos( radians( users.lat ) )
                * cos( radians( users.lng ) - radians(?)
                ) + sin( radians(?) ) *
                sin( radians( users.lat ) ) )
                ) AS distance",
                [$tech->lat, $tech->lng, $tech->lat]
            )
            ->orderBy('distance')
            ->with(['user', 'service'])
            ->paginate(20);

        return response()->json([
            'data' => $orders->items(),
            'meta' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'total' => $orders->total(),
            ],
        ]);
    }

    public function myOrders(): JsonResponse
    {
        $orders = Order::where('technician_id', auth()->id())
            ->with(['user', 'service'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'data' => $orders->items(),
            'meta' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'total' => $orders->total(),
            ],
        ]);
    }

    public function accept(Order $order): JsonResponse
    {
        try {
            DB::transaction(function () use ($order) {
                // Pessimistic lock to prevent race conditions (two techs accepting simultaneously)
                $lockedOrder = tap(Order::where('id', $order->id)->lockForUpdate()->first(), function ($o) {
                    if (!$o) {
                        throw new \Exception('Order not found.');
                    }
                    if ($o->status !== OrderStatus::PENDING_TECH->value || $o->technician_id !== null) {
                        throw new \Exception(__('messages.order_already_accepted', [], app()->getLocale() ?? 'en'));
                    }
                });

                $lockedOrder->update([
                    'technician_id' => auth()->id(),
                    'status' => OrderStatus::ACCEPTED->value,
                ]);
            });
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }

        return response()->json([
            'message' => __('messages.order_accepted_tech', [], app()->getLocale() ?? 'en'),
        ]);
    }

    public function updateStatus(Request $request, Order $order): JsonResponse
    {
        $request->validate([
            'status' => 'required|in:on_the_way,in_progress',
        ]);

        if ($order->technician_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Validate state transitions
        $current = $order->status;
        $new = $request->status;

        if ($new === OrderStatus::ON_THE_WAY->value && $current !== OrderStatus::ACCEPTED->value) {
            return response()->json(['message' => 'Invalid status transition'], 400);
        }
        
        if ($new === OrderStatus::IN_PROGRESS->value && $current !== OrderStatus::ON_THE_WAY->value) {
            return response()->json(['message' => 'Invalid status transition'], 400);
        }

        $order->update(['status' => $new]);

        return response()->json([
            'message' => __('messages.status_updated', [], app()->getLocale() ?? 'en'),
            'order' => $order,
        ]);
    }

    public function complete(\App\Services\OrderService $orderService, Order $order): JsonResponse
    {
        if ($order->technician_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $checklist = $order->checklist;
        if (!$checklist || (!$checklist->safety_checked && !$checklist->system_tested)) {
            return response()->json([
                'message' => 'يجب إتمام قائمة الفحص الرقمية (سلامة العمل واختبار التشغيل) قبل إغلاق الطلب.'
            ], 422);
        }

        try {
            $orderService->completeOrder($order);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }

        return response()->json([
            'message' => 'تم إنجاز الطلب وإغلاقه بنجاح، وتم تحويل المستحقات للمحفظة وتفعيل الضمان.',
            'order' => $order,
        ]);
    }
}

