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
            ->get();

        return response()->json([
            'data' => $requests,
        ]);
    }

    public function submitBid(SubmitBidRequest $request, CustomRequest $customRequest): JsonResponse
    {
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
            'notes' => $request->notes,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => __('messages.bid_submitted', [], app()->getLocale() ?? 'en'),
            'data' => $bid,
        ]);
    }

    public function myBids(): JsonResponse
    {
        $bids = Bid::where('technician_id', auth()->id())
            ->with(['customRequest.user', 'customRequest.images'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $bids,
        ]);
    }
}
