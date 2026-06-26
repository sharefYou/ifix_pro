<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\Customer\ServiceCategoryResource;
use App\Http\Resources\Api\V1\Customer\ServiceResource;
use App\Models\Service;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServiceController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = ServiceCategory::with('services')->get();

        return response()->json([
            'data' => ServiceCategoryResource::collection($categories),
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $query = $request->query('q', '');
        $locale = app()->getLocale();

        $categories = ServiceCategory::where("name->{$locale}", 'LIKE', "%{$query}%")
            ->orWhere("description->{$locale}", 'LIKE', "%{$query}%")
            ->get();

        $services = Service::with('category')
            ->where("name->{$locale}", 'LIKE', "%{$query}%")
            ->orWhere("description->{$locale}", 'LIKE', "%{$query}%")
            ->get();

        return response()->json([
            'categories' => ServiceCategoryResource::collection($categories),
            'services' => ServiceResource::collection($services),
        ]);
    }
}
