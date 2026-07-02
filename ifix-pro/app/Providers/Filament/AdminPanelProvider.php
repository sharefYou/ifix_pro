<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages\Dashboard;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets\AccountWidget;
use Filament\Widgets\FilamentInfoWidget;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery;
use Illuminate\Routing\Middleware\SubstituteBindings;
use App\Http\Middleware\SetLocale;
use Filament\Navigation\MenuItem;
use Filament\View\PanelsRenderHook;
use Illuminate\Support\Facades\Blade;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        $brandName = 'iFix Pro';
        $primaryColor = '#10b981';
        $fontFamily = 'Cairo';
        $logoUrl = null;

        try {
            if (\Illuminate\Support\Facades\Schema::hasTable('theme_settings')) {
                $theme = \App\Models\ThemeSetting::first();
                if ($theme) {
                    $brandName = $theme->brand_name ?? 'iFix Pro';
                    $primaryColor = $theme->primary_color ?? '#10b981';
                    $fontFamily = $theme->font_family ?? 'Cairo';
                    $logoUrl = $theme->logo_image ? asset('storage/' . $theme->logo_image) : null;
                }
            }
        } catch (\Exception $e) {
            // Ignore if DB not ready
        }

        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->brandName($brandName)
            ->font($fontFamily)
            ->brandLogo($logoUrl)
            ->sidebarCollapsibleOnDesktop()
            ->colors([
                'primary' => \Filament\Support\Colors\Color::hex($primaryColor),
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\Filament\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\Filament\Pages')
            ->pages([
                Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\Filament\Widgets')
            ->widgets([
                AccountWidget::class,
            ])
            ->userMenuItems([
                MenuItem::make()
                    ->label(fn () => app()->getLocale() === 'ar' ? 'English (EN)' : 'العربية (AR)')
                    ->url(fn () => route('change-locale', ['lang' => app()->getLocale() === 'ar' ? 'en' : 'ar']))
                    ->icon('heroicon-o-language'),
            ])
            ->renderHook(
                PanelsRenderHook::USER_MENU_BEFORE,
                fn () => Blade::render('
                    <a href="{{ route(\'change-locale\', [\'lang\' => app()->getLocale() === \'ar\' ? \'en\' : \'ar\']) }}"
                       style="
                           display: inline-flex;
                           align-items: center;
                           gap: 6px;
                           margin-inline-end: 10px;
                           padding: 5px 12px 5px 8px;
                           border-radius: 999px;
                           border: 1px solid rgba(var(--primary-500), 0.35);
                           background: rgba(var(--primary-500), 0.08);
                           color: rgb(var(--primary-600));
                           font-size: 12px;
                           font-weight: 600;
                           text-decoration: none;
                           cursor: pointer;
                           transition: background 0.2s, box-shadow 0.2s;
                           white-space: nowrap;
                           vertical-align: middle;
                           line-height: 1;
                       "
                       onmouseover="this.style.background=\'rgba(var(--primary-500),0.15)\'; this.style.boxShadow=\'0 2px 8px rgba(var(--primary-500),0.2)\'"
                       onmouseout="this.style.background=\'rgba(var(--primary-500),0.08)\'; this.style.boxShadow=\'none\'">
                        <span style="
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            width: 22px;
                            height: 22px;
                            border-radius: 50%;
                            background: rgb(var(--primary-500));
                            color: #fff;
                            font-size: 9px;
                            font-weight: 700;
                            line-height: 1;
                            flex-shrink: 0;
                        ">
                            {{ app()->getLocale() === \'ar\' ? \'EN\' : \'ع\' }}
                        </span>
                        <span style="letter-spacing: 0.01em;">
                            {{ app()->getLocale() === \'ar\' ? \'English\' : \'العربية\' }}
                        </span>
                    </a>
                ')
            )
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                \Illuminate\Session\Middleware\StartSession::class,
                SetLocale::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                PreventRequestForgery::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
