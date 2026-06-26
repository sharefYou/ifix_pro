<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Customer\AcceptBidRequest;
use App\Http\Requests\Api\V1\Customer\CreateCustomRequestRequest;
use App\Http\Resources\Api\V1\Customer\BidResource;
use App\Http\Resources\Api\V1\Customer\CustomRequestResource;
use App\Models\Bid;
use App\Models\CustomRequest;
use App\Models\Order;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class CustomRequestController extends Controller
{
    public function __construct(private WalletService $walletService)
    {
    }

    public function store(CreateCustomRequestRequest $request): JsonResponse
    {
        $data = $request->validated();
        
        $customRequest = CustomRequest::create([
            'user_id' => auth()->id(),
            'description' => $data['description'],
            'visit_date' => $data['visit_date'],
            'status' => 'pending',
        ]);

        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $file) {
                $path = $file->store('custom_requests', 'public');
                $customRequest->images()->create([
                    'path' => $path
                ]);
            }
        }

        return response()->json([
            'message' => __('messages.custom_request_created'),
            'data' => new CustomRequestResource($customRequest),
        ]);
    }

    public function bids(CustomRequest $customRequest): JsonResponse
    {
        if ($customRequest->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $bids = $customRequest->bids()->with('technician')->get();

        return response()->json([
            'data' => BidResource::collection($bids),
        ]);
    }

    public function acceptBid(AcceptBidRequest $request, CustomRequest $customRequest, Bid $bid): JsonResponse
    {
        if ($customRequest->user_id !== auth()->id() || $bid->custom_request_id !== $customRequest->id) {
            return response()->json(['message' => 'Unauthorized or Invalid Bid'], 403);
        }

        if ($customRequest->status !== 'pending' || $bid->status !== 'pending') {
            return response()->json(['message' => 'Bid cannot be accepted in current status'], 400);
        }

        $data = $request->validated();
        $agreedPrice = (float) $bid->price;
        $customer = auth()->user();

        DB::transaction(function () use ($customer, $customRequest, $bid, $agreedPrice, $data) {
            // 1. Hold funds via WalletService
            $this->walletService->holdFunds($customer, $agreedPrice);

            // 2. Transition Custom Request and Bid
            $customRequest->update(['status' => 'accepted']);
            $bid->update(['status' => 'accepted']);

            // 3. Reject other bids
            $customRequest->bids()->where('id', '!=', $bid->id)->update(['status' => 'rejected']);

            // 4. Create standard Order record
            Order::create([
                'user_id' => $customer->id,
                'technician_id' => $bid->technician_id,
                'service_id' => $data['service_id'],
                'status' => OrderStatus::ACCEPTED,
                'visit_type' => $data['visit_type'],
                'visit_date' => $customRequest->visit_date,
                'notes' => $customRequest->description,
                'payment_method' => $data['payment_method'],
                'total_amount' => $agreedPrice,
            ]);
        });

        return response()->json([
            'message' => __('messages.bid_accepted'),
        ]);
    }
}
