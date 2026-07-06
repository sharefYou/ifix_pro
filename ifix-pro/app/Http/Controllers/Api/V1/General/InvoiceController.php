<?php

namespace App\Http\Controllers\Api\V1\General;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class InvoiceController extends Controller
{
    public function show(Order $order): JsonResponse
    {
        if (auth()->id() !== $order->user_id && auth()->id() !== $order->technician_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $invoice = $order->invoice()->firstOrCreate([
            'order_id' => $order->id,
        ], [
            'invoice_number' => 'INV-' . date('Y') . '-' . str_pad($order->id, 5, '0', STR_PAD_LEFT),
            'labor_cost' => $order->total_amount * 0.70,
            'parts_cost' => $order->total_amount * 0.30,
            'discount_amount' => 0.00,
            'total_amount' => $order->total_amount,
        ]);

        return response()->json([
            'data' => [
                'invoice' => $invoice,
                'order' => $order->load(['user:id,name,phone,city', 'technician:id,name,phone', 'service:id,name']),
            ],
        ]);
    }

    public function download(Order $order): Response
    {
        if (auth()->id() !== $order->user_id && auth()->id() !== $order->technician_id) {
            abort(403, 'Unauthorized');
        }

        $invoice = $order->invoice()->firstOrCreate([
            'order_id' => $order->id,
        ], [
            'invoice_number' => 'INV-' . date('Y') . '-' . str_pad($order->id, 5, '0', STR_PAD_LEFT),
            'labor_cost' => $order->total_amount * 0.70,
            'parts_cost' => $order->total_amount * 0.30,
            'discount_amount' => 0.00,
            'total_amount' => $order->total_amount,
        ]);

        $order->load(['user:id,name,phone,city', 'technician:id,name,phone', 'service:id,name']);
        $locale = app()->getLocale() ?? 'en';
        $isRtl = $locale === 'ar';

        $html = view('invoices.simple', [
            'invoice' => $invoice,
            'order' => $order,
            'locale' => $locale,
            'isRtl' => $isRtl,
        ])->render();

        return response($html, 200, [
            'Content-Type' => 'text/html; charset=UTF-8',
        ]);
    }
}
