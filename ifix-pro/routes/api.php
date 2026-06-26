<?php

use App\Http\Controllers\Api\V1\Customer\AuthController;
use App\Http\Controllers\Api\V1\Customer\ProfileController;
use App\Http\Controllers\Api\V1\Customer\ServiceController;
use App\Http\Controllers\Api\V1\Customer\WalletController;
use App\Http\Controllers\Api\V1\Customer\OrderController;
use App\Http\Controllers\Api\V1\Technician\TrackingController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1/general')->middleware([\App\Http\Middleware\SetLocale::class])->group(function () {
    Route::get('/cities', [\App\Http\Controllers\Api\V1\General\GeneralController::class, 'cities']);
    Route::get('/faqs', [\App\Http\Controllers\Api\V1\General\GeneralController::class, 'faqs']);
    Route::get('/pages/{slug}', [\App\Http\Controllers\Api\V1\General\GeneralController::class, 'page']);
    Route::post('/contact-us', [\App\Http\Controllers\Api\V1\General\GeneralController::class, 'contactUs']);
});

Route::prefix('v1/customer')->group(function () {
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:otp_limiter');
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/resend-otp', [AuthController::class, 'resendOtp'])->middleware('throttle:otp_limiter');

    Route::get('/services', [ServiceController::class, 'index']);
    Route::get('/services/search', [ServiceController::class, 'search']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/profile', [ProfileController::class, 'show']);
        Route::post('/profile', [ProfileController::class, 'update']);

        Route::prefix('wallet')->group(function () {
            Route::get('/balance', [WalletController::class, 'balance']);
            Route::get('/transactions', [WalletController::class, 'transactions']);
            Route::post('/top-up', [WalletController::class, 'topUp']);
        });

        Route::prefix('orders')->group(function () {
            Route::post('/', [OrderController::class, 'store']);
            Route::post('/{order}/accept', [OrderController::class, 'acceptTechnician']);
            Route::post('/{order}/complete', [OrderController::class, 'complete']);
            Route::post('/{order}/cancel', [OrderController::class, 'cancel']);
            Route::post('/{order}/reviews', [OrderController::class, 'addReview']);
        });

        Route::prefix('custom-requests')->group(function () {
            Route::post('/', [\App\Http\Controllers\Api\V1\Customer\CustomRequestController::class, 'store']);
            Route::get('/{customRequest}/bids', [\App\Http\Controllers\Api\V1\Customer\CustomRequestController::class, 'bids']);
            Route::post('/{customRequest}/bids/{bid}/accept', [\App\Http\Controllers\Api\V1\Customer\CustomRequestController::class, 'acceptBid']);
        });
    });
});

Route::prefix('v1/technician')->group(function () {
    Route::post('/register', [\App\Http\Controllers\Api\V1\Technician\AuthController::class, 'register']);
    Route::post('/login', [\App\Http\Controllers\Api\V1\Technician\AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/profile', [\App\Http\Controllers\Api\V1\Technician\ProfileController::class, 'show']);
        Route::post('/profile', [\App\Http\Controllers\Api\V1\Technician\ProfileController::class, 'update']);
        Route::post('/toggle-online', [\App\Http\Controllers\Api\V1\Technician\ProfileController::class, 'toggleOnline']);

        Route::prefix('orders')->group(function () {
            Route::get('/available', [\App\Http\Controllers\Api\V1\Technician\OrderController::class, 'available']);
            Route::get('/my-orders', [\App\Http\Controllers\Api\V1\Technician\OrderController::class, 'myOrders']);
            Route::post('/{order}/accept', [\App\Http\Controllers\Api\V1\Technician\OrderController::class, 'accept']);
            Route::post('/{order}/status', [\App\Http\Controllers\Api\V1\Technician\OrderController::class, 'updateStatus']);
        });

        Route::post('/tracking/broadcast', [\App\Http\Controllers\Api\V1\Technician\TrackingController::class, 'updateLocation']);

        Route::prefix('custom-requests')->group(function () {
            Route::get('/available', [\App\Http\Controllers\Api\V1\Technician\CustomRequestController::class, 'available']);
            Route::get('/my-bids', [\App\Http\Controllers\Api\V1\Technician\CustomRequestController::class, 'myBids']);
            Route::post('/{customRequest}/bids', [\App\Http\Controllers\Api\V1\Technician\CustomRequestController::class, 'submitBid']);
        });

        Route::prefix('wallet')->group(function () {
            Route::get('/balance', [\App\Http\Controllers\Api\V1\Technician\WalletController::class, 'balance']);
            Route::get('/transactions', [\App\Http\Controllers\Api\V1\Technician\WalletController::class, 'transactions']);
            Route::post('/withdraw', [\App\Http\Controllers\Api\V1\Technician\WalletController::class, 'withdraw']);
        });
    });
});
