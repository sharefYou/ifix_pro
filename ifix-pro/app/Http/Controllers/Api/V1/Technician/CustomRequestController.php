<?php

namespace App\Http\Controllers\Api\V1\Technician;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Technician\SubmitBidRequest;
use App\Models\Bid;
use App\Models\CustomRequest;
use Illuminate\Http\JsonResponse;

class CustomRequestController extends Controller
{
    public function available(): JsonResponse
    {
        $tech = auth()->user();

        // Pending requests, matching tech's city, where tech hasn't bid
        $requests = CustomRequest::select('custom_requests.*')
            ->join('users', 'custom_requests.user_id', '=', 'users.id')
            ->where('custom_requests.status', 'pending')
            ->where('users.city', $tech->city)
            ->whereDoesntHave('bids', function ($query) use ($tech) {
                $query->where('technician_id', $tech->id);
            })
            ->with(['user', 'images'])
            ->orderBy('custom_requests.created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'data' => $requests->items(),
            'meta' => [
                'current_page' => $requests->currentPage(),
                'last_page' => $requests->lastPage(),
                'total' => $requests->total(),
            ],
        ]);
    }

    public function submitBid(SubmitBidRequest $request, CustomRequest $customRequest): JsonResponse
    {
        if ($customRequest->user_id === auth()->id()) {
            return response()->json([
                'message' => __('messages.cannot_bid_own_request', [], app()->getLocale() ?? 'en'),
            ], 403);
        }

        if ($customRequest->status !== 'pending') {
            return response()->json([
                'message' => __('messages.request_not_pending', [], app()->getLocale() ?? 'en'),
            ], 400);
        }

        $existingBid = Bid::where('custom_request_id', $customRequest->id)
            ->where('technician_id', auth()->id())
            ->exists();

        if ($existingBid) {
            return response()->json([
                'message' => __('messages.already_bid', [], app()->getLocale() ?? 'en'),
            ], 400);
        }

        $bid = Bid::create([
            'custom_request_id' => $customRequest->id,
            'technician_id' => auth()->id(),
            'price' => $request->price,
            'labor_cost' => $request->labor_cost,
            'parts_cost' => $request->parts_cost,
            'notes' => $request->notes,
            'status' => 'pending',
        ]);

        broadcast(new \App\Events\BidUpdated($bid, (string) $customRequest->user_id))->toOthers();

        return response()->json([
            'message' => __('messages.bid_submitted', [], app()->getLocale() ?? 'en'),
            'data' => $bid,
        ]);
    }

    public function counterOffer(\Illuminate\Http\Request $request, Bid $bid): JsonResponse
    {
        if ($bid->technician_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($bid->status !== 'pending') {
            return response()->json(['message' => 'Bid is not pending'], 400);
        }

        $validated = $request->validate([
            'counter_price' => ['required', 'numeric', 'min:0'],
            'counter_notes' => ['nullable', 'string', 'max:1000'],
        ]);

        $bid->update([
            'counter_price' => $validated['counter_price'],
            'counter_notes' => $validated['counter_notes'] ?? null,
            'counter_by' => 'technician',
            'counter_status' => 'pending',
        ]);

        broadcast(new \App\Events\BidUpdated($bid, (string) $bid->customRequest->user_id))->toOthers();

        return response()->json([
            'message' => 'Counter-offer submitted successfully',
            'data' => $bid,
        ]);
    }

    public function acceptCounterOffer(Bid $bid): JsonResponse
    {
        if ($bid->technician_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($bid->status !== 'pending' || $bid->counter_by !== 'customer' || $bid->counter_status !== 'pending') {
            return response()->json(['message' => 'No valid customer counter-offer to accept'], 400);
        }

        $bid->update([
            'price' => $bid->counter_price,
            'counter_status' => 'accepted',
        ]);

        broadcast(new \App\Events\BidUpdated($bid, (string) $bid->customRequest->user_id))->toOthers();

        return response()->json([
            'message' => 'Counter-offer accepted successfully. Waiting for customer final confirmation.',
            'data' => $bid,
        ]);
    }

    public function myBids(): JsonResponse
    {
        $bids = Bid::where('technician_id', auth()->id())
            ->with(['customRequest.user', 'customRequest.images'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'data' => $bids->items(),
            'meta' => [
                'current_page' => $bids->currentPage(),
                'last_page' => $bids->lastPage(),
                'total' => $bids->total(),
            ],
        ]);
    }
}
