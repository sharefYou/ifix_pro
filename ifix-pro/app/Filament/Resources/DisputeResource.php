<?php

namespace App\Filament\Resources;

use App\Enums\OrderStatus;
use App\Models\Dispute;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\DB;

class DisputeResource extends Resource
{
    protected static ?string $model = Dispute::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-scale';
    protected static ?int $navigationSort = 40;

    public static function getNavigationGroup(): ?string
    {
        return 'التشغيل والمتابعة الحية';
    }

    public static function getNavigationLabel(): string
    {
        return 'مركز فض النزاعات والتحكيم ⚖️';
    }

    public static function getModelLabel(): string
    {
        return 'نزاع رسمي';
    }

    public static function getPluralModelLabel(): string
    {
        return 'قضايا ونزاعات';
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('order_id')->label('رقم الطلب المتنازع عليه')->disabled(),
            TextInput::make('reason')->label('سبب النزاع')->disabled()->formatStateUsing(fn ($state) => match($state) {
                'quality_issue' => 'جودة الخدمة غير مرضية',
                'delay' => 'تأخير شديد في الإنجاز',
                'damage' => 'إلحاق ضرر بالممتلكات',
                'overcharge' => 'مطالبة مالية زائدة',
                default => $state,
            }),
            Textarea::make('description')->label('تفاصيل ومبررات الشكوى')->disabled()->columnSpanFull(),
            Select::make('status')->label('حالة النزاع والتحكيم')->options([
                'open' => 'مفتوح (بانتظار التحقيق)',
                'under_review' => 'قيد المراجعة والتواصل',
                'resolved_refund_customer' => 'تم الحسم: استرداد الرصيد للعميل',
                'resolved_release_tech' => 'تم الحسم: صرف المستحقات للفني',
                'resolved_split' => 'تم الحسم: تسوية ودية مشتركة',
            ])->required(),
            Textarea::make('admin_notes')->label('قرار لجنة التحكيم وأسباب الحكم (مرئي للأطراف)')->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('رقم القضية')->sortable(),
            TextColumn::make('order_id')->label('رقم الطلب')->sortable(),
            TextColumn::make('openedBy.name')->label('مقدم الشكوى')->searchable(),
            TextColumn::make('reason')->label('السبب')->formatStateUsing(fn ($state) => match($state) {
                'quality_issue' => 'جودة سيئة',
                'delay' => 'تأخير',
                'damage' => 'أضرار',
                'overcharge' => 'مطالبة مالية',
                default => $state,
            }),
            TextColumn::make('status')->label('الحالة')->badge()->color(fn ($state) => match($state) {
                'open' => 'danger',
                'under_review' => 'warning',
                default => 'success',
            })->formatStateUsing(fn ($state) => match($state) {
                'open' => 'مفتوح للتحقيق',
                'under_review' => 'قيد المراجعة',
                'resolved_refund_customer' => 'حكم للعميل',
                'resolved_release_tech' => 'حكم للفني',
                'resolved_split' => 'تسوية مشتركة',
                default => $state,
            }),
            TextColumn::make('created_at')->label('تاريخ الرفع')->dateTime('Y-m-d H:i')->sortable(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
            Action::make('refund_customer')
                ->label('الحكم للعميل (استرداد) ↩️')
                ->color('danger')
                ->icon('heroicon-s-arrow-uturn-left')
                ->visible(fn (Dispute $record) => in_array($record->status, ['open', 'under_review']))
                ->requiresConfirmation()
                ->modalHeading('تأكيد الحكم لصالح العميل')
                ->modalDescription('سيتم إغلاق النزاع واسترداد كامل الرصيد المعلق في الضمان إلى رصيد العميل المتاح وإلغاء الطلب.')
                ->action(function (Dispute $record) {
                    DB::transaction(function () use ($record) {
                        $order = $record->order;
                        if ($order && $order->user) {
                            $wallet = Wallet::where('user_id', $order->user_id)->lockForUpdate()->first();
                            if ($wallet && $wallet->held_balance >= $order->total_amount) {
                                $amount = (float) $order->total_amount;
                                $wallet->decrement('held_balance', $amount);
                                $wallet->increment('available_balance', $amount);

                                WalletTransaction::create([
                                    'wallet_id' => $wallet->id,
                                    'type' => 'refund',
                                    'amount' => $amount,
                                    'reference_type' => 'dispute_arbitration_customer',
                                    'reference_id' => $record->id,
                                    'status' => 'completed',
                                ]);
                            }
                            $order->update(['status' => OrderStatus::CANCELED]);
                        }

                        $record->update([
                            'status' => 'resolved_refund_customer',
                            'resolved_by_admin_id' => auth()->id() ?? 1,
                            'resolved_at' => now(),
                            'admin_notes' => 'تم دراسة الأدلة والحكم باسترداد الرصيد للعميل بسبب عدم استيفاء معايير الجودة.',
                        ]);
                    });

                    Notification::make()->title('تم الحكم لصالح العميل واسترداد الضمان')->success()->send();
                }),

            Action::make('release_tech')
                ->label('الحكم للفني (صرف) ✅')
                ->color('success')
                ->icon('heroicon-s-check-badge')
                ->visible(fn (Dispute $record) => in_array($record->status, ['open', 'under_review']))
                ->requiresConfirmation()
                ->modalHeading('تأكيد الحكم لصالح الفني')
                ->modalDescription('سيتم إغلاق النزاع وتحرير الرصيد المعلق في الضمان وإيداعه في محفظة الفني واعتماد اكتمال الطلب.')
                ->action(function (Dispute $record) {
                    DB::transaction(function () use ($record) {
                        $order = $record->order;
                        if ($order && $order->technician_id) {
                            $techWallet = Wallet::firstOrCreate(['user_id' => $order->technician_id], ['available_balance' => 0, 'held_balance' => 0]);
                            $customerWallet = Wallet::where('user_id', $order->user_id)->lockForUpdate()->first();

                            $amount = (float) $order->total_amount;
                            if ($customerWallet && $customerWallet->held_balance >= $amount) {
                                $customerWallet->decrement('held_balance', $amount);
                            }

                            $techWallet->increment('available_balance', $amount);

                            WalletTransaction::create([
                                'wallet_id' => $techWallet->id,
                                'type' => 'deposit',
                                'amount' => $amount,
                                'reference_type' => 'dispute_arbitration_tech',
                                'reference_id' => $record->id,
                                'status' => 'completed',
                            ]);

                            $order->update(['status' => OrderStatus::COMPLETED]);
                        }

                        $record->update([
                            'status' => 'resolved_release_tech',
                            'resolved_by_admin_id' => auth()->id() ?? 1,
                            'resolved_at' => now(),
                            'admin_notes' => 'تم التحقق من إنجاز العمل ومطابقته للمواصفات وصرف المستحقات للفني.',
                        ]);
                    });

                    Notification::make()->title('تم الحكم لصالح الفني وصرف المستحقات')->success()->send();
                }),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\DisputeResource\Pages\ManageDisputes::route('/'),
        ];
    }
}
