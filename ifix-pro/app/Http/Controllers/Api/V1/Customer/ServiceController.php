<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\Customer\ServiceCategoryResource;
use App\Http\Resources\Api\V1\Customer\ServiceResource;
use App\Models\Service;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServiceController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = ServiceCategory::with('services')->get();

        return response()->json([
            'data' => ServiceCategoryResource::collection($categories),
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $query = $request->query('q', '');
        $locale = app()->getLocale();

        $categories = ServiceCategory::where("name->{$locale}", 'LIKE', "%{$query}%")
            ->orWhere("description->{$locale}", 'LIKE', "%{$query}%")
            ->get();

        $services = Service::with('category')
            ->where("name->{$locale}", 'LIKE', "%{$query}%")
            ->orWhere("description->{$locale}", 'LIKE', "%{$query}%")
            ->get();

        return response()->json([
            'categories' => ServiceCategoryResource::collection($categories),
            'services' => ServiceResource::collection($services),
        ]);
    }

    public function calculateCost(Request $request): JsonResponse
    {
        $data = $request->validate([
            'service_id'       => 'required|exists:services,id',
            'urgency'          => 'nullable|string|in:normal,urgent,emergency',
            'quantity'         => 'nullable|integer|min:1|max:100',
            'has_vip_discount' => 'nullable|boolean',
        ]);

        $service = Service::findOrFail($data['service_id']);
        $quantity = $data['quantity'] ?? 1;
        $urgency = $data['urgency'] ?? 'normal';
        $hasVip = $data['has_vip_discount'] ?? false;

        $basePrice = (float) $service->price * $quantity;
        
        $urgencyMultiplier = match ($urgency) {
            'urgent'    => 1.3,
            'emergency' => 1.6,
            default     => 1.0,
        };

        $surgeMultiplier = \App\Models\SurgeRule::getCurrentMultiplier();
        $totalMultiplier = $urgencyMultiplier * $surgeMultiplier;

        $subtotal = $basePrice * $totalMultiplier;
        $discountAmount = $hasVip ? round($subtotal * 0.15, 2) : 0.00;
        $estimatedTotal = round($subtotal - $discountAmount, 2);

        return response()->json([
            'service_id'         => $service->id,
            'service_name'       => $service->name,
            'unit_price'         => (float) $service->price,
            'quantity'           => $quantity,
            'urgency'            => $urgency,
            'urgency_multiplier' => $urgencyMultiplier,
            'surge_multiplier'   => $surgeMultiplier,
            'is_surge_active'    => $surgeMultiplier > 1.0,
            'subtotal'           => round($subtotal, 2),
            'discount_amount'    => $discountAmount,
            'estimated_total'    => $estimatedTotal,
        ]);
    }
}
