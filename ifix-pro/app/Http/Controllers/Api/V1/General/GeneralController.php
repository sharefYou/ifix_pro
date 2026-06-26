<?php

namespace App\Http\Controllers\Api\V1\General;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\General\ContactUsRequest;
use App\Models\City;
use App\Models\ContactMessage;
use App\Models\Faq;
use App\Models\Page;
use Illuminate\Http\JsonResponse;

class GeneralController extends Controller
{
    public function cities(): JsonResponse
    {
        $cities = City::where('is_active', true)->get()->map(function ($city) {
            return [
                'id' => $city->id,
                'name' => $city->name, // spatie/laravel-translatable handles current locale
            ];
        });

        return response()->json(['data' => $cities]);
    }

    public function faqs(): JsonResponse
    {
        $faqs = Faq::where('is_active', true)->orderBy('sort_order')->get()->map(function ($faq) {
            return [
                'id' => $faq->id,
                'question' => $faq->question,
                'answer' => $faq->answer,
            ];
        });

        return response()->json(['data' => $faqs]);
    }

    public function page(string $slug): JsonResponse
    {
        $page = Page::where('slug', $slug)->first();

        if (!$page) {
            return response()->json(['message' => 'Page not found'], 404);
        }

        return response()->json([
            'data' => [
                'slug' => $page->slug,
                'title' => $page->title,
                'content' => $page->content,
            ]
        ]);
    }

    public function contactUs(ContactUsRequest $request): JsonResponse
    {
        ContactMessage::create($request->validated());

        return response()->json([
            'message' => __('messages.contact_message_sent', [], app()->getLocale() ?? 'en'),
        ]);
    }
}
