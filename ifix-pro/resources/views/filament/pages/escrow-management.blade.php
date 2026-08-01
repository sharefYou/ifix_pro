<x-filament-panels::page>
<style>
    .em-wrap { direction: rtl; font-family: 'Cairo', 'Segoe UI', sans-serif; }
    
    /* Stats Section */
    .em-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; }
    @media(max-width: 768px) { .em-stats { grid-template-columns: 1fr; } }
    
    .em-stat-card { 
        border-radius: 16px; padding: 24px; display: flex; align-items: center; justify-content: space-between; 
        border: 1px solid rgba(0,0,0,0.05); box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }
    
    .em-stat-card.escrow {
        background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(245, 158, 11, 0.03));
        border-color: rgba(245, 158, 11, 0.2);
    }
    .dark .em-stat-card.escrow { background: linear-gradient(135deg, rgba(146, 64, 14, 0.4), rgba(120, 53, 15, 0.1)); border-color: rgba(180, 83, 9, 0.4); }
    
    .em-stat-card.available {
        background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(16, 185, 129, 0.03));
        border-color: rgba(16, 185, 129, 0.2);
    }
    .dark .em-stat-card.available { background: linear-gradient(135deg, rgba(6, 78, 59, 0.4), rgba(2, 44, 34, 0.1)); border-color: rgba(4, 120, 87, 0.4); }

    .em-stat-label { font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; }
    .em-stat-card.escrow .em-stat-label { color: #d97706; } .dark .em-stat-card.escrow .em-stat-label { color: #fbbf24; }
    .em-stat-card.available .em-stat-label { color: #059669; } .dark .em-stat-card.available .em-stat-label { color: #34d399; }
    
    .em-stat-val-wrap { margin-top: 8px; display: flex; align-items: baseline; gap: 8px; }
    .em-stat-value { font-size: 36px; font-weight: 800; color: #111827; line-height: 1; font-family: monospace; }
    .dark .em-stat-value { color: #f9fafb; }
    
    .em-stat-currency { font-size: 14px; font-weight: 700; }
    .em-stat-card.escrow .em-stat-currency { color: #d97706; } .dark .em-stat-card.escrow .em-stat-currency { color: #fbbf24; }
    .em-stat-card.available .em-stat-currency { color: #059669; } .dark .em-stat-card.available .em-stat-currency { color: #34d399; }
    
    .em-stat-desc { font-size: 12px; color: #6b7280; margin-top: 6px; }
    .dark .em-stat-desc { color: #9ca3af; }

    .em-stat-icon { width: 56px; height: 56px; border-radius: 16px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .em-stat-card.escrow .em-stat-icon { background: rgba(245, 158, 11, 0.2); color: #d97706; }
    .dark .em-stat-card.escrow .em-stat-icon { background: rgba(251, 191, 36, 0.2); color: #fbbf24; }
    .em-stat-card.available .em-stat-icon { background: rgba(16, 185, 129, 0.2); color: #059669; }
    .dark .em-stat-card.available .em-stat-icon { background: rgba(52, 211, 153, 0.2); color: #34d399; }
    .em-stat-icon svg { width: 32px; height: 32px; }

    /* Table Section */
    .em-panel { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 4px rgba(0,0,0,.06); overflow: hidden; }
    .dark .em-panel { background: #1f2937; border-color: #374151; }
    
    .em-panel-header { padding: 20px 24px; border-bottom: 1px solid #f3f4f6; display: flex; align-items: center; justify-content: space-between; }
    .dark .em-panel-header { border-color: #374151; }
    
    .em-panel-title-wrap { display: flex; align-items: center; gap: 12px; }
    .em-pulse { width: 12px; height: 12px; border-radius: 50%; display: inline-block; position: relative; flex-shrink: 0; background: #f59e0b; }
    .em-pulse::after { content:''; position: absolute; inset: -4px; border-radius: 50%; background: #fbbf24; opacity: .6; animation: ping 1.5s cubic-bezier(0,0,.2,1) infinite; }
    
    .em-panel-title { font-size: 18px; font-weight: 700; color: #111827; }
    .dark .em-panel-title { color: #f9fafb; }

    .em-empty { text-align: center; padding: 60px 20px; color: #9ca3af; }
    .em-empty svg { width: 56px; height: 56px; margin: 0 auto 16px; color: #10b981; opacity: 0.8; }
    .em-empty p { font-size: 16px; font-weight: 600; }

    .em-table-wrap { overflow-x: auto; }
    .em-table { width: 100%; text-align: right; border-collapse: collapse; }
    .em-th { padding: 14px 20px; border-bottom: 1px solid #e5e7eb; font-size: 12px; font-weight: 700; color: #6b7280; text-transform: uppercase; white-space: nowrap; }
    .dark .em-th { border-color: #4b5563; color: #9ca3af; }
    
    .em-tr { transition: background 0.15s; border-bottom: 1px solid #f3f4f6; }
    .dark .em-tr { border-color: #374151; }
    .em-tr:hover { background: #f9fafb; }
    .dark .em-tr:hover { background: rgba(255,255,255,0.03); }
    .em-tr:last-child { border-bottom: none; }
    
    .em-td { padding: 16px 20px; font-size: 14px; vertical-align: middle; }
    
    .em-user-name { font-weight: 700; color: #111827; }
    .dark .em-user-name { color: #f9fafb; }
    .em-user-phone { font-size: 12px; color: #9ca3af; margin-top: 2px; }
    
    .em-role { display: inline-block; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; }
    .em-role-tech { background: #e0e7ff; color: #3730a3; } .dark .em-role-tech { background: rgba(49,46,129,0.5); color: #a5b4fc; }
    .em-role-cust { background: #f3f4f6; color: #1f2937; } .dark .em-role-cust { background: rgba(55,65,81,0.5); color: #d1d5db; }
    
    .em-avail-bal { font-family: monospace; font-weight: 700; color: #059669; }
    .dark .em-avail-bal { color: #34d399; }
    
    .em-held-badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: 8px; font-family: monospace; font-weight: 800; font-size: 14px; background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
    .dark .em-held-badge { background: rgba(69,26,3,0.4); color: #fbbf24; border-color: #92400e; }
    
    .em-actions { display: flex; align-items: center; justify-content: center; gap: 10px; flex-wrap: wrap; }
    .em-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px; border-radius: 8px; font-size: 12px; font-weight: 700; color: #fff; cursor: pointer; border: none; font-family: inherit; transition: opacity 0.15s; white-space: nowrap; }
    .em-btn:hover { opacity: 0.9; } .em-btn:disabled { opacity: 0.6; cursor: not-allowed; }
    .em-btn svg { width: 16px; height: 16px; }
    
    .em-btn-release { background: #059669; }
    .em-btn-release:hover { background: #047857; }
    .em-btn-refund { background: #e11d48; }
    .em-btn-refund:hover { background: #be123c; }
</style>

<div class="em-wrap">

    <!-- Top KPI Cards -->
    <div class="em-stats">
        <!-- Held in Escrow Card -->
        <div class="em-stat-card escrow">
            <div>
                <div class="em-stat-label">أموال تحت الحجز والضمان (Escrow Balance) 🔒</div>
                <div class="em-stat-val-wrap">
                    <span class="em-stat-value">{{ number_format($this->totalEscrow, 2) }}</span>
                    <span class="em-stat-currency">ريال</span>
                </div>
                <div class="em-stat-desc">مبالغ محجوزة للطلبات الجارية وبانتظار الإنجاز أو التسوية</div>
            </div>
            <div class="em-stat-icon">
                <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
            </div>
        </div>

        <!-- Total Available Balance Card -->
        <div class="em-stat-card available">
            <div>
                <div class="em-stat-label">إجمالي الأرصدة المتاحة (Available Balances) 💰</div>
                <div class="em-stat-val-wrap">
                    <span class="em-stat-value">{{ number_format($this->totalAvailable, 2) }}</span>
                    <span class="em-stat-currency">ريال</span>
                </div>
                <div class="em-stat-desc">أرصدة حرة قابلة للسحب أو الاستخدام الفوري في المنصة</div>
            </div>
            <div class="em-stat-icon">
                <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/></svg>
            </div>
        </div>
    </div>

    <!-- Escrow Accounts Table/List -->
    <div class="em-panel">
        <div class="em-panel-header">
            <div class="em-panel-title-wrap">
                <span class="em-pulse"></span>
                <span class="em-panel-title">الحسابات والمحافظ ذات الأرصدة المعلقة بالضمان ({{ count($this->escrowWallets) }})</span>
            </div>
        </div>

        @if(count($this->escrowWallets) === 0)
            <div class="em-empty">
                <svg fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                <p>لا توجد مبالغ معلقة في الضمان حالياً، جميع الحسابات تمت تسويتها!</p>
            </div>
        @else
            <div class="em-table-wrap">
                <table class="em-table">
                    <thead>
                        <tr>
                            <th class="em-th">المستخدم / صاحب المحفظة</th>
                            <th class="em-th">نوع الحساب</th>
                            <th class="em-th">الرصيد المتاح</th>
                            <th class="em-th">المبلغ المحجوز بالضمان</th>
                            <th class="em-th text-center" style="text-align: center;">إجراءات التسوية اليدوية (Admin Override)</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($this->escrowWallets as $wallet)
                            <tr class="em-tr">
                                <td class="em-td">
                                    <div class="em-user-name">{{ $wallet->user->name ?? 'مستخدم غير معروف' }}</div>
                                    <div class="em-user-phone">{{ $wallet->user->phone ?? '-' }}</div>
                                </td>
                                <td class="em-td">
                                    @if($wallet->user->is_technician)
                                        <span class="em-role em-role-tech">فني صيانة</span>
                                    @else
                                        <span class="em-role em-role-cust">عميل</span>
                                    @endif
                                </td>
                                <td class="em-td">
                                    <span class="em-avail-bal">{{ number_format($wallet->available_balance, 2) }} ريال</span>
                                </td>
                                <td class="em-td">
                                    <span class="em-held-badge">🔒 {{ number_format($wallet->held_balance, 2) }} ريال</span>
                                </td>
                                <td class="em-td" style="text-align: center;">
                                    <div class="em-actions">
                                        <button 
                                            wire:click="releaseEscrow({{ $wallet->id }})"
                                            wire:confirm="هل أنت متأكد من تحرير الرصيد المعلق ({{ number_format($wallet->held_balance, 2) }} ريال) إلى الرصيد المتاح لـ {{ $wallet->user->name ?? '' }}؟"
                                            wire:loading.attr="disabled"
                                            class="em-btn em-btn-release">
                                            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                                            تحرير للمستفيد ✅
                                        </button>
                                        <button 
                                            wire:click="refundEscrow({{ $wallet->id }})"
                                            wire:confirm="هل أنت متأكد من استرداد المبلغ المعلق ({{ number_format($wallet->held_balance, 2) }} ريال) وإعادته لـ {{ $wallet->user->name ?? '' }}؟"
                                            wire:loading.attr="disabled"
                                            class="em-btn em-btn-refund">
                                            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"/></svg>
                                            استرداد للعميل ↩️
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>

</div>
</x-filament-panels::page>
