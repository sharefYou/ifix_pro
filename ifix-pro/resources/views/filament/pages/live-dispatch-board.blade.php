<x-filament-panels::page>
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6" dir="rtl">
        <!-- Pending Orders Column -->
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-center justify-between mb-6 pb-4 border-b border-gray-100 dark:border-gray-700">
                <div class="flex items-center gap-3">
                    <span class="flex h-3 w-3 relative">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-3 w-3 bg-amber-500"></span>
                    </span>
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white font-cairo">
                        الطلبات المعلقة وبانتظار التوجيه ({{ count($this->pendingOrders) }})
                    </h3>
                </div>
            </div>

            @if(count($this->pendingOrders) === 0)
                <div class="text-center py-12 text-gray-400 dark:text-gray-500 font-cairo">
                    <x-heroicon-o-check-circle class="w-12 h-12 mx-auto mb-3 text-emerald-500 opacity-80" />
                    <p class="text-base font-medium">لا توجد طلبات معلقة حالياً، جميع الطلبات تم توجيهها بنجاح!</p>
                </div>
            @else
                <div class="space-y-4">
                    @foreach($this->pendingOrders as $order)
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 border border-gray-200/80 dark:border-gray-700 transition hover:border-primary-500">
                            <div class="flex items-start justify-between mb-3">
                                <div>
                                    <span class="inline-block px-2.5 py-1 text-xs font-bold bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300 rounded-md mb-2">
                                        طلب #{{ $order->id }}
                                    </span>
                                    <h4 class="font-bold text-gray-900 dark:text-white font-cairo text-base">
                                        {{ $order->service->name_ar ?? $order->service->name ?? 'خدمة صيانة' }}
                                    </h4>
                                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-1 font-cairo">
                                        العميل: {{ $order->user->name ?? 'عميل' }} • المبلغ: {{ number_format($order->total_amount, 2) }} ريال
                                    </p>
                                </div>
                                <button 
                                    wire:click="triggerAiDispatch({{ $order->id }})"
                                    wire:loading.attr="disabled"
                                    class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white text-xs font-bold rounded-lg shadow-sm transition font-cairo">
                                    <x-heroicon-s-sparkles class="w-4 h-4 animate-pulse" />
                                    <span>توجيه ذكي AI 🤖</span>
                                </button>
                            </div>

                            <div class="mt-4 pt-3 border-t border-gray-200 dark:border-gray-800">
                                <label class="block text-xs font-semibold text-gray-600 dark:text-gray-400 mb-2 font-cairo">
                                    توجيه يدوي مباشر لفني متاح:
                                </label>
                                <div class="flex flex-wrap gap-2">
                                    @forelse($this->activeTechnicians as $tech)
                                        <button 
                                            wire:click="assignOrder({{ $order->id }}, {{ $tech->id }})"
                                            wire:confirm="هل أنت متأكد من توجيه الطلب #{{ $order->id }} إلى الفني {{ $tech->name }}؟"
                                            class="inline-flex items-center gap-1 px-2.5 py-1 bg-white dark:bg-gray-800 hover:bg-emerald-50 dark:hover:bg-emerald-950/30 text-gray-700 dark:text-gray-200 border border-gray-300 dark:border-gray-600 hover:border-emerald-500 rounded text-xs font-cairo transition">
                                            <span class="w-2 h-2 rounded-full {{ $tech->active_orders_count == 0 ? 'bg-emerald-500' : 'bg-amber-500' }}"></span>
                                            <span>{{ $tech->name }}</span>
                                            <span class="text-gray-400">({{ $tech->active_orders_count }} طلب نشط)</span>
                                        </button>
                                    @empty
                                        <span class="text-xs text-rose-500 font-cairo">لا يوجد فنيون متصلون حالياً</span>
                                    @endforelse
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>
            @endif
        </div>

        <!-- Active Technicians Column -->
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-center justify-between mb-6 pb-4 border-b border-gray-100 dark:border-gray-700">
                <div class="flex items-center gap-3">
                    <span class="flex h-3 w-3 relative">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-3 w-3 bg-emerald-500"></span>
                    </span>
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white font-cairo">
                        الفنيون المتصلون حالياً ({{ count($this->activeTechnicians) }})
                    </h3>
                </div>
            </div>

            @if(count($this->activeTechnicians) === 0)
                <div class="text-center py-12 text-gray-400 dark:text-gray-500 font-cairo">
                    <x-heroicon-o-user-group class="w-12 h-12 mx-auto mb-3 text-gray-400 opacity-60" />
                    <p class="text-base font-medium">لا يوجد فنيون متصلون (Online) حالياً على المنصة.</p>
                </div>
            @else
                <div class="grid grid-cols-1 gap-4">
                    @foreach($this->activeTechnicians as $tech)
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 border border-gray-200/80 dark:border-gray-700 flex items-center justify-between">
                            <div class="flex items-center gap-3.5">
                                <div class="w-10 h-10 rounded-full bg-primary-100 dark:bg-primary-900/40 text-primary-600 dark:text-primary-300 flex items-center justify-center font-bold text-base">
                                    {{ mb_substr($tech->name, 0, 1) }}
                                </div>
                                <div>
                                    <div class="flex items-center gap-2">
                                        <h4 class="font-bold text-gray-900 dark:text-white font-cairo text-base">
                                            {{ $tech->name }}
                                        </h4>
                                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300">
                                            ⭐ {{ number_format($tech->avg_tech_rating ?? 5.0, 1) }}
                                        </span>
                                    </div>
                                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5 font-cairo">
                                        الهاتف: {{ $tech->phone ?? 'غير محدد' }} • آخر ظهور: {{ $tech->last_seen_at ? $tech->last_seen_at->diffForHumans() : 'الآن' }}
                                    </p>
                                </div>
                            </div>

                            <div class="text-left flex flex-col items-end gap-1">
                                @if($tech->active_orders_count == 0)
                                    <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-300 font-cairo">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                                        متاح فوراً
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300 font-cairo">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                        مشغول ({{ $tech->active_orders_count }} طلب)
                                    </span>
                                @endif
                                <span class="text-xs text-gray-400 font-mono">
                                    {{ $tech->lat ? number_format($tech->lat, 4) . ', ' . number_format($tech->lng, 4) : 'موقع غير محدد' }}
                                </span>
                            </div>
                        </div>
                    @endforeach
                </div>
            @endif
        </div>
    </div>
</x-filament-panels::page>
