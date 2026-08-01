<x-filament-panels::page>
<style>
    .db-wrap { direction: rtl; font-family: 'Cairo', 'Segoe UI', sans-serif; }
    .db-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
    .db-stat-card { background: #fff; border-radius: 14px; padding: 20px 24px; border: 1px solid #e5e7eb; display: flex; align-items: center; gap: 16px; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
    .dark .db-stat-card { background: #1f2937; border-color: #374151; }
    .db-stat-icon { width: 52px; height: 52px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .db-stat-icon svg { width: 28px; height: 28px; }
    .db-stat-label { font-size: 12px; color: #6b7280; margin-bottom: 4px; }
    .db-stat-value { font-size: 32px; font-weight: 800; color: #111827; line-height: 1; }
    .dark .db-stat-value { color: #f9fafb; }

    .db-cols { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    @media(max-width: 900px) { .db-cols { grid-template-columns: 1fr; } .db-stats { grid-template-columns: 1fr; } }

    .db-panel { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 4px rgba(0,0,0,.06); overflow: hidden; }
    .dark .db-panel { background: #1f2937; border-color: #374151; }
    .db-panel-header { padding: 16px 20px; border-bottom: 1px solid #f3f4f6; display: flex; align-items: center; gap: 10px; }
    .dark .db-panel-header { border-color: #374151; }
    .db-panel-title { font-size: 15px; font-weight: 700; color: #111827; }
    .dark .db-panel-title { color: #f9fafb; }
    .db-panel-body { padding: 16px; }

    .db-pulse { width: 10px; height: 10px; border-radius: 50%; display: inline-block; position: relative; flex-shrink: 0; }
    .db-pulse::after { content:''; position: absolute; inset: -3px; border-radius: 50%; animation: ping 1.5s cubic-bezier(0,0,.2,1) infinite; }
    .db-pulse-amber { background: #f59e0b; } .db-pulse-amber::after { background: #fbbf24; opacity: .6; }
    .db-pulse-green { background: #10b981; } .db-pulse-green::after { background: #34d399; opacity: .6; }
    @keyframes ping { 0%{transform:scale(1);opacity:.7} 75%,100%{transform:scale(2);opacity:0} }

    .db-empty { text-align: center; padding: 40px 16px; color: #9ca3af; }
    .db-empty svg { width: 48px; height: 48px; margin: 0 auto 12px; }
    .db-empty p { font-size: 14px; }

    .order-card { border: 1px solid #e5e7eb; border-radius: 12px; padding: 14px; margin-bottom: 10px; background: #f9fafb; transition: border-color .15s; }
    .order-card:hover { border-color: #6366f1; }
    .dark .order-card { background: rgba(255,255,255,.04); border-color: #374151; }
    .order-card:last-child { margin-bottom: 0; }
    .order-card-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px; }
    .order-badge { display: inline-block; background: #fef3c7; color: #92400e; border-radius: 6px; padding: 2px 10px; font-size: 11px; font-weight: 700; margin-bottom: 6px; }
    .order-title { font-size: 14px; font-weight: 700; color: #111827; }
    .dark .order-title { color: #f9fafb; }
    .order-meta { font-size: 12px; color: #6b7280; margin-top: 3px; }

    .ai-btn { display: inline-flex; align-items: center; gap: 6px; padding: 7px 14px; background: linear-gradient(135deg,#6366f1,#8b5cf6); color: #fff; border: none; border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer; white-space: nowrap; transition: opacity .15s; font-family: inherit; }
    .ai-btn:hover { opacity: .9; } .ai-btn:disabled { opacity: .6; cursor: not-allowed; }
    .ai-btn svg { width: 15px; height: 15px; }

    .assign-section { border-top: 1px solid #e5e7eb; margin-top: 10px; padding-top: 10px; }
    .dark .assign-section { border-color: #374151; }
    .assign-label { font-size: 11px; font-weight: 600; color: #6b7280; margin-bottom: 8px; }
    .assign-btns { display: flex; flex-wrap: wrap; gap: 6px; }
    .tech-btn { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border: 1px solid #d1d5db; border-radius: 6px; background: #fff; color: #374151; font-size: 11px; cursor: pointer; transition: all .15s; font-family: inherit; }
    .dark .tech-btn { background: #374151; color: #d1d5db; border-color: #4b5563; }
    .tech-btn:hover { border-color: #10b981; background: #ecfdf5; color: #065f46; }
    .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; flex-shrink: 0; }
    .dot-green { background: #10b981; } .dot-amber { background: #f59e0b; }
    .no-tech { font-size: 12px; color: #ef4444; }

    .tech-card { display: flex; align-items: center; justify-content: space-between; padding: 12px; border-radius: 10px; border: 1px solid #e5e7eb; background: #f9fafb; margin-bottom: 8px; }
    .dark .tech-card { background: rgba(255,255,255,.04); border-color: #374151; }
    .tech-card:last-child { margin-bottom: 0; }
    .tech-avatar { width: 40px; height: 40px; border-radius: 50%; background: #ede9fe; color: #6d28d9; font-weight: 800; font-size: 16px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .tech-name { font-size: 14px; font-weight: 700; color: #111827; }
    .dark .tech-name { color: #f9fafb; }
    .tech-sub { font-size: 11px; color: #6b7280; margin-top: 2px; }
    .tech-info { display: flex; align-items: center; gap: 12px; }
    .tech-meta { display: flex; flex-direction: column; gap: 4px; align-items: flex-end; }
    .badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; }
    .badge-green { background: #dcfce7; color: #166534; }
    .badge-amber { background: #fef9c3; color: #854d0e; }
    .tech-coords { font-size: 10px; color: #9ca3af; font-family: monospace; }
    .tech-rating { display: inline-flex; align-items: center; gap: 3px; background: #fef9c3; color: #854d0e; border-radius: 5px; padding: 1px 7px; font-size: 11px; font-weight: 700; margin-right: 6px; }
</style>

<div class="db-wrap">

    {{-- Stats --}}
    <div class="db-stats">
        <div class="db-stat-card">
            <div class="db-stat-icon" style="background:#fef3c7;">
                <svg fill="none" stroke="#d97706" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <div>
                <div class="db-stat-label">الطلبات بانتظار التوجيه</div>
                <div class="db-stat-value">{{ count($this->pendingOrders) }}</div>
            </div>
        </div>
        <div class="db-stat-card">
            <div class="db-stat-icon" style="background:#dcfce7;">
                <svg fill="none" stroke="#16a34a" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <div>
                <div class="db-stat-label">الفنيون المتصلون الآن</div>
                <div class="db-stat-value">{{ count($this->activeTechnicians) }}</div>
            </div>
        </div>
    </div>

    <div class="db-cols">

        {{-- Pending Orders --}}
        <div class="db-panel">
            <div class="db-panel-header">
                <span class="db-pulse db-pulse-amber"></span>
                <span class="db-panel-title">الطلبات المعلقة — بانتظار التوجيه ({{ count($this->pendingOrders) }})</span>
            </div>
            <div class="db-panel-body">
                @if(count($this->pendingOrders) === 0)
                    <div class="db-empty">
                        <svg fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        <p>لا توجد طلبات معلقة — جميع الطلبات تم توجيهها!</p>
                    </div>
                @else
                    @foreach($this->pendingOrders as $order)
                        <div class="order-card">
                            <div class="order-card-top">
                                <div>
                                    <div class="order-badge">طلب #{{ $order->id }}</div>
                                    <div class="order-title">{{ $order->service->name_ar ?? $order->service->name ?? 'خدمة صيانة' }}</div>
                                    <div class="order-meta">العميل: {{ $order->user->name ?? 'عميل' }} &bull; {{ number_format($order->total_amount, 2) }} ريال</div>
                                </div>
                                <button
                                    wire:click="triggerAiDispatch({{ $order->id }})"
                                    wire:loading.attr="disabled"
                                    class="ai-btn">
                                    <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M5 3l14 9-14 9V3z"/></svg>
                                    توجيه ذكي AI 🤖
                                </button>
                            </div>
                            <div class="assign-section">
                                <div class="assign-label">توجيه يدوي لفني متاح:</div>
                                <div class="assign-btns">
                                    @forelse($this->activeTechnicians as $tech)
                                        <button
                                            wire:click="assignOrder({{ $order->id }}, {{ $tech->id }})"
                                            wire:confirm="هل أنت متأكد من توجيه الطلب #{{ $order->id }} إلى الفني {{ $tech->name }}؟"
                                            class="tech-btn">
                                            <span class="dot {{ $tech->active_orders_count == 0 ? 'dot-green' : 'dot-amber' }}"></span>
                                            {{ $tech->name }} ({{ $tech->active_orders_count }})
                                        </button>
                                    @empty
                                        <span class="no-tech">لا يوجد فنيون متصلون</span>
                                    @endforelse
                                </div>
                            </div>
                        </div>
                    @endforeach
                @endif
            </div>
        </div>

        {{-- Active Technicians --}}
        <div class="db-panel">
            <div class="db-panel-header">
                <span class="db-pulse db-pulse-green"></span>
                <span class="db-panel-title">الفنيون المتصلون الآن ({{ count($this->activeTechnicians) }})</span>
            </div>
            <div class="db-panel-body">
                @if(count($this->activeTechnicians) === 0)
                    <div class="db-empty">
                        <svg fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z"/></svg>
                        <p>لا يوجد فنيون متصلون حالياً</p>
                    </div>
                @else
                    @foreach($this->activeTechnicians as $tech)
                        <div class="tech-card">
                            <div class="tech-info">
                                <div class="tech-avatar">{{ mb_substr($tech->name, 0, 1) }}</div>
                                <div>
                                    <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                                        <span class="tech-name">{{ $tech->name }}</span>
                                        <span class="tech-rating">⭐ {{ number_format($tech->avg_tech_rating ?? 5.0, 1) }}</span>
                                    </div>
                                    <div class="tech-sub">
                                        {{ $tech->phone ?? 'بدون رقم' }}
                                        @if($tech->last_seen_at) &bull; {{ $tech->last_seen_at->diffForHumans() }} @endif
                                    </div>
                                </div>
                            </div>
                            <div class="tech-meta">
                                @if($tech->active_orders_count == 0)
                                    <span class="badge badge-green">
                                        <span class="dot dot-green" style="animation:ping 1.5s infinite;"></span>
                                        متاح فوراً
                                    </span>
                                @else
                                    <span class="badge badge-amber">مشغول ({{ $tech->active_orders_count }})</span>
                                @endif
                                <span class="tech-coords">
                                    {{ $tech->lat ? number_format($tech->lat, 4).', '.number_format($tech->lng, 4) : 'موقع غير محدد' }}
                                </span>
                            </div>
                        </div>
                    @endforeach
                @endif
            </div>
        </div>

    </div>
</div>
</x-filament-panels::page>
