<?php

namespace App\Filament\Resources;

use App\Models\SurgeRule;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SurgeRuleResource extends Resource
{
    protected static ?string $model = SurgeRule::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-bolt';
    protected static ?int $navigationSort = 20;

    public static function getNavigationGroup(): ?string
    {
        return 'التشغيل والمتابعة الحية';
    }

    public static function getNavigationLabel(): string
    {
        return 'قواعد التسعير الديناميكي (Surge Pricing) ⚡';
    }

    public static function getModelLabel(): string
    {
        return 'قاعدة تسعير';
    }

    public static function getPluralModelLabel(): string
    {
        return 'قواعد التسعير';
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name_ar')->label('اسم القاعدة (عربي)')->required()->maxLength(255),
            TextInput::make('name_en')->label('اسم القاعدة (إنجليزي)')->maxLength(255),
            TextInput::make('multiplier')->label('معامل الزيادة (مثال: 1.25 أو 1.50)')->numeric()->required()->default(1.25)->minValue(1.0)->maxValue(5.0),
            Select::make('condition_type')->label('نوع الشرط')->options([
                'time_based' => 'مبني على الوقت والأيام (Time Based)',
                'manual' => 'تفعيل يدوي فوري (Manual Override)',
                'weather' => 'ظروف طقس سيئة / أمطار (Weather)',
                'emergency' => 'حالة طوارئ عامة (Emergency)',
            ])->default('time_based')->required()->reactive(),
            TimePicker::make('start_time')->label('وقت البدء')->visible(fn ($get) => $get('condition_type') === 'time_based'),
            TimePicker::make('end_time')->label('وقت الانتهاء')->visible(fn ($get) => $get('condition_type') === 'time_based'),
            Select::make('days_of_week')->label('أيام الأسبوع')->multiple()->options([
                'Sunday' => 'الأحد',
                'Monday' => 'الاثنين',
                'Tuesday' => 'الثلاثاء',
                'Wednesday' => 'الأربعاء',
                'Thursday' => 'الخميس',
                'Friday' => 'الجمعة',
                'Saturday' => 'السبت',
            ])->visible(fn ($get) => $get('condition_type') === 'time_based'),
            Toggle::make('is_active')->label('تفعيل القاعدة')->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('name_ar')->label('اسم القاعدة')->searchable()->sortable(),
            TextColumn::make('multiplier')->label('المعامل')->formatStateUsing(fn ($state) => "{$state}x")->sortable(),
            TextColumn::make('condition_type')->label('النوع')->formatStateUsing(fn ($state) => match($state) {
                'time_based' => 'مبني على الوقت',
                'manual' => 'تفعيل يدوي',
                'weather' => 'طقس سيئ',
                'emergency' => 'طوارئ',
                default => $state,
            }),
            TextColumn::make('start_time')->label('البدء')->time('H:i'),
            TextColumn::make('end_time')->label('الانتهاء')->time('H:i'),
            IconColumn::make('is_active')->label('مفعل')->boolean(),
        ])
        ->actions([
            \Filament\Actions\EditAction::make(),
            \Filament\Actions\DeleteAction::make(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => \App\Filament\Resources\SurgeRuleResource\Pages\ManageSurgeRules::route('/'),
        ];
    }
}
