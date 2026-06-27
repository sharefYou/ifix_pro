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
        $orders = Order::with(['service', 'technician'])->where('user_id', auth()->id())->latest()->get();

        return response()->json([
            'data' => $orders,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'service_id' => 'required|exists:services,id',
            'visit_type' => 'required|string',
            'visit_date' => 'required|date',
            'notes' => 'nullable|string',
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
}
