<!DOCTYPE html>
<html lang="{{ $locale }}" dir="{{ $isRtl ? 'rtl' : 'ltr' }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice {{ $invoice->invoice_number }}</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&family=Inter:wght@400;600;700&display=swap');
        
        body {
            font-family: {{ $isRtl ? "'Cairo', sans-serif" : "'Inter', sans-serif" }};
            background-color: #f8f9fa;
            color: #212529;
            margin: 0;
            padding: 40px 20px;
            direction: {{ $isRtl ? 'rtl' : 'ltr' }};
        }
        .invoice-box {
            max-width: 700px;
            margin: auto;
            background: #ffffff;
            padding: 40px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #2979ff;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .title {
            font-size: 28px;
            font-weight: 700;
            color: #2979ff;
            margin: 0;
        }
        .invoice-meta {
            text-align: {{ $isRtl ? 'left' : 'right' }};
            font-size: 14px;
            color: #6c757d;
        }
        .invoice-meta strong {
            color: #212529;
            display: block;
            font-size: 16px;
        }
        .section-title {
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #6c757d;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        .info-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            border: 1px solid #dee2e6;
        }
        .info-card p {
            margin: 4px 0;
            font-size: 14px;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            margin-bottom: 30px;
        }
        .table th, .table td {
            padding: 14px;
            text-align: {{ $isRtl ? 'right' : 'left' }};
            border-bottom: 1px solid #dee2e6;
        }
        .table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #495057;
            font-size: 14px;
        }
        .table td {
            font-size: 15px;
        }
        .amount-col {
            text-align: {{ $isRtl ? 'left' : 'right' }} !important;
            font-weight: 600;
        }
        .summary-wrapper {
            display: flex;
            justify-content: {{ $isRtl ? 'flex-start' : 'flex-end' }};
        }
        .summary-table {
            width: 280px;
            border-collapse: collapse;
        }
        .summary-table td {
            padding: 8px 0;
            font-size: 15px;
        }
        .summary-table .total-row td {
            font-weight: 700;
            font-size: 18px;
            color: #2979ff;
            border-top: 2px solid #212529;
            padding-top: 12px;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
            text-align: center;
            font-size: 13px;
            color: #6c757d;
        }
        @media print {
            body {
                background: #fff;
                padding: 0;
            }
            .invoice-box {
                box-shadow: none;
                border: none;
                padding: 20px 0;
            }
        }
    </style>
</head>
<body>
    <div class="invoice-box">
        <div class="header">
            <h1 class="title">{{ $isRtl ? 'فاتورة مالية' : 'INVOICE' }}</h1>
            <div class="invoice-meta">
                <strong>{{ $invoice->invoice_number }}</strong>
                <span>{{ $isRtl ? 'التاريخ:' : 'Date:' }} {{ $invoice->created_at->format('Y-m-d') }}</span>
            </div>
        </div>

        <div class="grid">
            <div class="info-card">
                <div class="section-title">{{ $isRtl ? 'بيانات العميل' : 'Customer Details' }}</div>
                <p><strong>{{ $order->user->name ?? ($isRtl ? 'عميل' : 'Customer') }}</strong></p>
                <p>{{ $order->user->phone ?? '' }}</p>
                <p>{{ $order->user->city ?? '' }}</p>
            </div>
            <div class="info-card">
                <div class="section-title">{{ $isRtl ? 'بيانات الطلب والفني' : 'Order & Technician' }}</div>
                <p><strong>{{ $isRtl ? 'الخدمة:' : 'Service:' }}</strong> {{ $order->service->name ?? ($isRtl ? 'خدمة صيانة' : 'Maintenance Service') }}</p>
                <p><strong>{{ $isRtl ? 'رقم الطلب:' : 'Order ID:' }}</strong> #{{ $order->id }}</p>
                <p><strong>{{ $isRtl ? 'الفني:' : 'Technician:' }}</strong> {{ $order->technician->name ?? ($isRtl ? 'غير محدد' : 'N/A') }}</p>
            </div>
        </div>

        <table class="table">
            <thead>
                <tr>
                    <th>{{ $isRtl ? 'البيان / الوصف' : 'Description' }}</th>
                    <th class="amount-col">{{ $isRtl ? 'المبلغ' : 'Amount' }}</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>{{ $isRtl ? 'تكلفة العمالة والصيانة' : 'Labor & Maintenance Service Cost' }}</td>
                    <td class="amount-col">{{ number_format($invoice->labor_cost, 2) }}</td>
                </tr>
                <tr>
                    <td>{{ $isRtl ? 'تكلفة قطع الغيار والمواد' : 'Parts & Materials Cost' }}</td>
                    <td class="amount-col">{{ number_format($invoice->parts_cost, 2) }}</td>
                </tr>
                @if($invoice->discount_amount > 0)
                <tr>
                    <td style="color: #2e7d32;">{{ $isRtl ? 'خصم المنصة' : 'Platform Discount' }}</td>
                    <td class="amount-col" style="color: #2e7d32;">- {{ number_format($invoice->discount_amount, 2) }}</td>
                </tr>
                @endif
            </tbody>
        </table>

        <div class="summary-wrapper">
            <table class="summary-table">
                <tr>
                    <td>{{ $isRtl ? 'المجموع الفرعي:' : 'Subtotal:' }}</td>
                    <td class="amount-col">{{ number_format($invoice->labor_cost + $invoice->parts_cost, 2) }}</td>
                </tr>
                @if($invoice->discount_amount > 0)
                <tr>
                    <td>{{ $isRtl ? 'الخصم:' : 'Discount:' }}</td>
                    <td class="amount-col">- {{ number_format($invoice->discount_amount, 2) }}</td>
                </tr>
                @endif
                <tr class="total-row">
                    <td>{{ $isRtl ? 'الإجمالي النهائي:' : 'Final Total:' }}</td>
                    <td class="amount-col">{{ number_format($invoice->total_amount, 2) }} {{ $isRtl ? 'ر.س' : 'SAR' }}</td>
                </tr>
            </table>
        </div>

        <div class="footer">
            <p>{{ $isRtl ? 'شكراً لثقتكم بخدماتنا. هذه فاتورة إلكترونية مبسطة غير خاضعة للحسابات الضريبية المعقدة.' : 'Thank you for choosing our services. This is a simple financial invoice.' }}</p>
            <p>&copy; {{ date('Y') }} iFix Open Marketplace.</p>
        </div>
    </div>
</body>
</html>
