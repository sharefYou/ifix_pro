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
    protected static string|\UnitEnum|null $navigationGroup = 'Settings';
    protected static ?string $navigationLabel = 'Theme Settings';
    protected static ?string $title = 'Manage Theme';
    protected static ?int $navigationSort = 100;

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
                Section::make('Branding')
                    ->components([
                        TextInput::make('brand_name')
                            ->label('Brand Name')
                            ->required()
                            ->maxLength(255),
                        FileUpload::make('logo_image')
                            ->label('Logo Image')
                            ->image()
                            ->directory('settings')
                            ->maxSize(2048),
                    ])->columns(2),

                Section::make('Appearance')
                    ->components([
                        ColorPicker::make('primary_color')
                            ->label('Primary Color (Hex)')
                            ->required(),
                        Select::make('font_family')
                            ->label('Font Family')
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
            ->title('Theme settings saved successfully')
            ->success()
            ->send();
    }
}
