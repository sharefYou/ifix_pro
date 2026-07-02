<?php

use Illuminate\Support\Facades\Route;

Route::get('/locale/{lang}', function (string $lang) {
    if (in_array($lang, ['en', 'ar'])) {
        session()->put('locale', $lang);
    }
    return redirect()->back();
})->name('change-locale');

Route::redirect('/', '/admin', 301);
