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

    public function index(): JsonResponse
    {
        $requests = CustomRequest::where('user_id', auth()->id())->latest()->paginate(20);

        return response()->json([
            'data' => CustomRequestResource::collection($requests->items()),
            'meta' => [
                'current_page' => $requests->currentPage(),
                'last_page' => $requests->lastPage(),
                'total' => $requests->total(),
            ],
        ]);
    }

    public function store(CreateCustomRequestRequest $request): JsonResponse
    {
        $data = $request->validated();
        
        $customRequest = CustomRequest::create([
            'user_id' => auth()->id(),
            'description' => $data['description'],
            'visit_date' => $data['visit_date'],
            'status' => 'pending',
            'audio_memo_path' => $data['audio_memo_path'] ?? null,
            'video_path' => $data['video_path'] ?? null,
        ]);

        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $file) {
                $path = $file->store('custom_requests', 'public');
                $customRequest->images()->create([
                    'path' => $path
                ]);
            }
        }

        broadcast(new \App\Events\CustomRequestCreated($customRequest))->toOthers();

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

        $bids = $customRequest->bids()->with('technician')->paginate(20);

        return response()->json([
            'data' => BidResource::collection($bids->items()),
            'meta' => [
                'current_page' => $bids->currentPage(),
                'last_page' => $bids->lastPage(),
                'total' => $bids->total(),
            ],
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

        broadcast(new \App\Events\BidUpdated($bid, (string) $bid->technician_id))->toOthers();

        return response()->json([
            'message' => __('messages.bid_accepted'),
        ]);
    }

    public function counterOffer(\Illuminate\Http\Request $request, CustomRequest $customRequest, Bid $bid): JsonResponse
    {
        if ($customRequest->user_id !== auth()->id() || $bid->custom_request_id !== $customRequest->id) {
            return response()->json(['message' => 'Unauthorized or Invalid Bid'], 403);
        }

        if ($customRequest->status !== 'pending' || $bid->status !== 'pending') {
            return response()->json(['message' => 'Bid cannot be countered in current status'], 400);
        }

        $validated = $request->validate([
            'counter_price' => ['required', 'numeric', 'min:0'],
            'counter_notes' => ['nullable', 'string', 'max:1000'],
        ]);

        $bid->update([
            'counter_price' => $validated['counter_price'],
            'counter_notes' => $validated['counter_notes'] ?? null,
            'counter_by' => 'customer',
            'counter_status' => 'pending',
        ]);

        broadcast(new \App\Events\BidUpdated($bid, (string) $bid->technician_id))->toOthers();

        return response()->json([
            'message' => 'Counter-offer submitted successfully',
            'data' => $bid,
        ]);
    }

    public function acceptCounterOffer(AcceptBidRequest $request, CustomRequest $customRequest, Bid $bid): JsonResponse
    {
        if ($customRequest->user_id !== auth()->id() || $bid->custom_request_id !== $customRequest->id) {
            return response()->json(['message' => 'Unauthorized or Invalid Bid'], 403);
        }

        if ($customRequest->status !== 'pending' || $bid->status !== 'pending' || $bid->counter_by !== 'technician' || $bid->counter_status !== 'pending') {
            return response()->json(['message' => 'No valid technician counter-offer to accept'], 400);
        }

        $bid->update([
            'price' => $bid->counter_price,
            'counter_status' => 'accepted',
        ]);

        return $this->acceptBid($request, $customRequest, $bid);
    }
}
