<x-filament-panels::page>
    <div class="space-y-6" dir="rtl">
        <!-- Top KPI Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Held in Escrow Card -->
            <div class="bg-gradient-to-br from-amber-500/10 via-amber-500/5 to-transparent dark:from-amber-900/40 dark:via-amber-900/20 rounded-2xl p-6 border border-amber-500/30 shadow-sm flex items-center justify-between">
                <div>
                    <span class="text-xs font-bold uppercase tracking-wider text-amber-600 dark:text-amber-400 font-cairo">
                        أموال تحت الحجز والضمان (Escrow Balance) 🔒
                    </span>
                    <div class="mt-2 flex items-baseline gap-2">
                        <span class="text-3xl font-extrabold text-gray-900 dark:text-white font-mono">
                            {{ number_format($this->totalEscrow, 2) }}
                        </span>
                        <span class="text-sm font-bold text-amber-600 dark:text-amber-400 font-cairo">ريال</span>
                    </div>
                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-1 font-cairo">
                        مبالغ محجوزة للطلبات الجارية وبانتظار الإنجاز أو التسوية
                    </p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-amber-500/20 flex items-center justify-center text-amber-600 dark:text-amber-400">
                    <x-heroicon-o-lock-closed class="w-8 h-8" />
                </div>
            </div>

            <!-- Total Available Balance Card -->
            <div class="bg-gradient-to-br from-emerald-500/10 via-emerald-500/5 to-transparent dark:from-emerald-900/40 dark:via-emerald-900/20 rounded-2xl p-6 border border-emerald-500/30 shadow-sm flex items-center justify-between">
                <div>
                    <span class="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 font-cairo">
                        إجمالي الأرصدة المتاحة (Available Balances) 💰
                    </span>
                    <div class="mt-2 flex items-baseline gap-2">
                        <span class="text-3xl font-extrabold text-gray-900 dark:text-white font-mono">
                            {{ number_format($this->totalAvailable, 2) }}
                        </span>
                        <span class="text-sm font-bold text-emerald-600 dark:text-emerald-400 font-cairo">ريال</span>
                    </div>
                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-1 font-cairo">
                        أرصدة حرة قابلة للسحب أو الاستخدام الفوري في المنصة
                    </p>
                </div>
                <div class="w-14 h-14 rounded-2xl bg-emerald-500/20 flex items-center justify-center text-emerald-600 dark:text-emerald-400">
                    <x-heroicon-o-wallet class="w-8 h-8" />
                </div>
            </div>
        </div>

        <!-- Escrow Accounts Table/List -->
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-center justify-between mb-6 pb-4 border-b border-gray-100 dark:border-gray-700">
                <div class="flex items-center gap-3">
                    <span class="flex h-3 w-3 relative">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-3 w-3 bg-amber-500"></span>
                    </span>
                    <h3 class="text-lg font-bold text-gray-900 dark:text-white font-cairo">
                        الحسابات والمحافظ ذات الأرصدة المعلقة بالضمان ({{ count($this->escrowWallets) }})
                    </h3>
                </div>
            </div>

            @if(count($this->escrowWallets) === 0)
                <div class="text-center py-12 text-gray-400 dark:text-gray-500 font-cairo">
                    <x-heroicon-o-shield-check class="w-12 h-12 mx-auto mb-3 text-emerald-500 opacity-80" />
                    <p class="text-base font-medium">لا توجد مبالغ معلقة في الضمان حالياً، جميع الحسابات تمت تسويتها!</p>
                </div>
            @else
                <div class="overflow-x-auto">
                    <table class="w-full text-right border-collapse font-cairo">
                        <thead>
                            <tr class="border-b border-gray-200 dark:border-gray-700 text-gray-500 dark:text-gray-400 text-xs font-bold uppercase">
                                <th class="py-3 px-4">المستخدم / صاحب المحفظة</th>
                                <th class="py-3 px-4">نوع الحساب</th>
                                <th class="py-3 px-4">الرصيد المتاح</th>
                                <th class="py-3 px-4">المبلغ المحجوز بالضمان</th>
                                <th class="py-3 px-4 text-center">إجراءات التسوية اليدوية (Admin Override)</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-gray-800 text-sm">
                            @foreach($this->escrowWallets as $wallet)
                                <tr class="hover:bg-gray-50 dark:hover:bg-gray-900/50 transition">
                                    <td class="py-4 px-4 font-bold text-gray-900 dark:text-white">
                                        {{ $wallet->user->name ?? 'مستخدم غير معروف' }}
                                        <div class="text-xs font-normal text-gray-400">{{ $wallet->user->phone ?? '-' }}</div>
                                    </td>
                                    <td class="py-4 px-4">
                                        @if($wallet->user->is_technician)
                                            <span class="inline-flex px-2 py-0.5 rounded text-xs font-bold bg-indigo-100 text-indigo-800 dark:bg-indigo-900/40 dark:text-indigo-300">
                                                فني صيانة
                                            </span>
                                        @else
                                            <span class="inline-flex px-2 py-0.5 rounded text-xs font-bold bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300">
                                                عميل
                                            </span>
                                        @endif
                                    </td>
                                    <td class="py-4 px-4 font-mono text-emerald-600 dark:text-emerald-400 font-bold">
                                        {{ number_format($wallet->balance, 2) }} ريال
                                    </td>
                                    <td class="py-4 px-4">
                                        <span class="inline-flex items-center gap-1 font-mono text-amber-600 dark:text-amber-400 font-extrabold bg-amber-50 dark:bg-amber-950/40 px-3 py-1 rounded-lg border border-amber-200 dark:border-amber-800">
                                            🔒 {{ number_format($wallet->held_balance, 2) }} ريال
                                        </span>
                                    </td>
                                    <td class="py-4 px-4 text-center">
                                        <div class="inline-flex items-center gap-2 justify-center">
                                            <button 
                                                wire:click="releaseEscrow({{ $wallet->id }})"
                                                wire:confirm="هل أنت متأكد من تحرير الرصيد المعلق ({{ number_format($wallet->held_balance, 2) }} ريال) إلى الرصيد المتاح للمستخدم {{ $wallet->user->name ?? '' }}؟"
                                                wire:loading.attr="disabled"
                                                class="inline-flex items-center gap-1 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-lg shadow-sm transition">
                                                <x-heroicon-s-check-circle class="w-4 h-4" />
                                                <span>تحرير للمستفيد ✅</span>
                                            </button>
                                            <button 
                                                wire:click="refundEscrow({{ $wallet->id }})"
                                                wire:confirm="هل أنت متأكد من استرداد المبلغ المعلق ({{ number_format($wallet->held_balance, 2) }} ريال) وإعادته للعميل {{ $wallet->user->name ?? '' }}؟"
                                                wire:loading.attr="disabled"
                                                class="inline-flex items-center gap-1 px-3 py-1.5 bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold rounded-lg shadow-sm transition">
                                                <x-heroicon-s-arrow-uturn-left class="w-4 h-4" />
                                                <span>استرداد للعميل ↩️</span>
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
