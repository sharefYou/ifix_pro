<?php

namespace App\Filament\Pages;

use App\Enums\OrderStatus;
use App\Jobs\AutoAssignTechnician;
use App\Models\Order;
use App\Models\User;
use Filament\Notifications\Notification;
use Filament\Pages\Page;

class LiveDispatchBoard extends Page
{
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-map';
    protected static ?int $navigationSort = 10;

    public static function getNavigationGroup(): ?string
    {
        return 'التشغيل والمتابعة الحية';
    }

    public static function getNavigationLabel(): string
    {
        return 'لوحة التوجيه الذكي (Dispatch Board) 🛰️';
    }

    public function getTitle(): string
    {
        return 'لوحة التوجيه الذكي ومراقبة الفنيين';
    }

    protected string $view = 'filament.pages.live-dispatch-board';

    public function getPendingOrdersProperty()
    {
        return Order::with(['user', 'service'])
            ->where('status', OrderStatus::PENDING_TECH)
            ->latest()
            ->get();
    }

    public function getActiveTechniciansProperty()
    {
        return User::where('is_technician', true)
            ->where('is_active', true)
            ->where('is_online', true)
            ->withCount(['technicianOrders as active_orders_count' => function ($query) {
                $query->whereIn('status', [OrderStatus::ACCEPTED, OrderStatus::ON_THE_WAY, OrderStatus::IN_PROGRESS]);
            }])
            ->withAvg('technicianReviews as avg_tech_rating', 'avg_rating')
            ->get();
    }

    public function assignOrder(int $orderId, int $technicianId): void
    {
        $order = Order::find($orderId);
        $tech = User::find($technicianId);

        if ($order && $tech && $order->status === OrderStatus::PENDING_TECH) {
            $order->update([
                'technician_id' => $tech->id,
                'status' => OrderStatus::ACCEPTED,
            ]);

            Notification::make()
                ->title('تم توجيه الطلب بنجاح!')
                ->body("تم تعيين الطلب #{$order->id} للفني {$tech->name}")
                ->success()
                ->send();
        }
    }

    public function triggerAiDispatch(int $orderId): void
    {
        $order = Order::find($orderId);
        if ($order && $order->status === OrderStatus::PENDING_TECH) {
            AutoAssignTechnician::dispatchSync($order);

            $order->refresh();
            if ($order->technician_id) {
                Notification::make()
                    ->title('تم التوجيه الذكي بنجاح! 🤖')
                    ->body("قام محرك الذكاء الاصطناعي باختيار الفني الأنسب للطلب #{$order->id}")
                    ->success()
                    ->send();
            } else {
                Notification::make()
                    ->title('تنبيه التوجيه الذكي')
                    ->body("لم يتم العثور على فني متاح ومناسب ضمن النطاق حالياً للطلب #{$order->id}")
                    ->warning()
                    ->send();
            }
        }
    }
}
