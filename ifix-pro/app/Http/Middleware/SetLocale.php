<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SetLocale
{
    public function handle(Request $request, Closure $next): Response
    {
        // يقرأ Accept-Language header من تطبيق الموبايل أولاً
        $headerLocale = $request->header('Accept-Language');
        $locale = $headerLocale && in_array($headerLocale, ['ar', 'en'])
            ? $headerLocale
            : session('locale', config('app.locale', 'ar'));

        app()->setLocale($locale);

        return $next($request);
    }
}
