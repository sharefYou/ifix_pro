<?php

namespace App\Filament\Pages;

use App\Models\ThemeSetting;
use Filament\Forms\Components\ColorPicker;
use Filament\Forms\Components\FileUpload;
use Filament\Schemas\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Schemas\Schema;
use Filament\Notifications\Notification;
use Filament\Pages\Page;

class ManageTheme extends Page implements HasForms
{
    use InteractsWithForms;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-paint-brush';
    protected static ?int $navigationSort = 100;

    public static function getNavigationGroup(): ?string
    {
        return __('admin.group_settings');
    }

    public static function getNavigationLabel(): string
    {
        return __('admin.theme_settings');
    }

    public function getTitle(): string
    {
        return __('admin.manage_theme');
    }

    protected string $view = 'filament.pages.manage-theme';

    public ?array $data = [];

    public function mount(): void
    {
        $theme = ThemeSetting::first() ?? new ThemeSetting();
        $this->form->fill($theme->toArray());
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make(fn() => __('admin.branding'))
                    ->components([
                        TextInput::make('brand_name')
                            ->label(__('admin.brand_name'))
                            ->required()
                            ->maxLength(255),
                        FileUpload::make('logo_image')
                            ->label(__('admin.logo_image'))
                            ->image()
                            ->directory('settings')
                            ->maxSize(2048),
                        Select::make('currency')
                            ->label('نوع العملة المعتمدة')
                            ->options([
                                'SYP' => 'ليرة سورية (ل.س / SYP)',
                                'USD' => 'دولار أمريكي ($ / USD)',
                            ])
                            ->default('SYP')
                            ->required(),
                    ])->columns(2),

                Section::make(fn() => __('admin.appearance'))
                    ->components([
                        ColorPicker::make('primary_color')
                            ->label(__('admin.primary_color'))
                            ->required(),
                        Select::make('font_family')
                            ->label(__('admin.font_family'))
                            ->options([
                                'Cairo' => 'Cairo',
                                'Tajawal' => 'Tajawal',
                                'Inter' => 'Inter',
                                'Roboto' => 'Roboto',
                                'Outfit' => 'Outfit',
                            ])
                            ->required(),
                    ])->columns(2),
            ])
            ->statePath('data');
    }

    public function save(): void
    {
        $theme = ThemeSetting::first() ?? new ThemeSetting();
        $theme->fill($this->form->getState());
        $theme->save();

        Notification::make()
            ->title(__('admin.theme_saved'))
            ->success()
            ->send();
    }
}
