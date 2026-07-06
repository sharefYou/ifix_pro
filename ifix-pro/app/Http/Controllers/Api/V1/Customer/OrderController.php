<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Review;
use App\Services\OrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function __construct(private OrderService $orderService)
    {
    }

    public function index(): JsonResponse
    {
        $orders = Order::with(['service', 'technician'])->where('user_id', auth()->id())->latest()->paginate(20);

        return response()->json([
            'data' => $orders->items(),
            'meta' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'total' => $orders->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'service_id' => 'required|exists:services,id',
            'visit_type' => 'required|string',
            'visit_date' => 'required|date',
            'notes' => 'nullable|string',
            'audio_memo_path' => 'nullable|string|max:1024',
            'video_path' => 'nullable|string|max:1024',
            'payment_method' => 'required|string',
            'total_amount' => 'required|numeric',
        ]);

        $order = $this->orderService->createOrder(auth()->user(), $data);

        return response()->json([
            'message' => __('messages.order_created'),
            'order' => $order,
        ]);
    }

    public function acceptTechnician(Request $request, Order $order): JsonResponse
    {
        $request->validate([
            'technician_id' => 'required|exists:users,id',
        ]);

        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $order->update([
            'technician_id' => $request->technician_id,
            'status' => OrderStatus::ACCEPTED,
        ]);

        return response()->json([
            'message' => __('messages.technician_accepted'),
            'order' => $order,
        ]);
    }

    public function complete(Order $order): JsonResponse
    {
        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $this->orderService->completeOrder($order);

        return response()->json([
            'message' => __('messages.order_completed'),
        ]);
    }

    public function cancel(Order $order): JsonResponse
    {
        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $this->orderService->cancelOrder($order);

        return response()->json([
            'message' => __('messages.order_canceled'),
        ]);
    }

    public function addReview(Request $request, Order $order): JsonResponse
    {
        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $data = $request->validate([
            'time_rating' => 'required|integer|min:1|max:5',
            'quality_rating' => 'required|integer|min:1|max:5',
            'cleanliness_rating' => 'required|integer|min:1|max:5',
        ]);

        $avg = ($data['time_rating'] + $data['quality_rating'] + $data['cleanliness_rating']) / 3;

        $review = Review::create([
            'order_id' => $order->id,
            'user_id' => auth()->id(),
            'technician_id' => $order->technician_id,
            'time_rating' => $data['time_rating'],
            'quality_rating' => $data['quality_rating'],
            'cleanliness_rating' => $data['cleanliness_rating'],
            'avg_rating' => $avg,
        ]);

        return response()->json([
            'message' => __('messages.review_added'),
            'review' => $review,
        ]);
    }

    public function claimWarranty(Order $order): JsonResponse
    {
        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== OrderStatus::COMPLETED || $order->warranty_status !== 'active' || $order->warranty_expires_at < now()) {
            return response()->json(['message' => 'Order is not eligible for warranty claim.'], 400);
        }

        $claimOrder = Order::create([
            'parent_order_id' => $order->id,
            'user_id'         => auth()->id(),
            'technician_id'   => $order->technician_id,
            'service_id'      => $order->service_id,
            'status'          => OrderStatus::ACCEPTED,
            'visit_type'      => 'normal',
            'visit_date'      => now()->addDay(),
            'notes'           => "Warranty Claim for Order #{$order->id}",
            'payment_method'  => 'warranty',
            'total_amount'    => 0.00,
        ]);

        $order->update(['warranty_status' => 'claimed']);

        return response()->json([
            'message' => __('messages.warranty_claimed', [], app()->getLocale() ?? 'en'),
            'order'   => $claimOrder,
        ], 201);
    }
}
