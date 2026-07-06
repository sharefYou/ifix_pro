<?php

namespace App\Http\Controllers\Api\V1\General;

use App\Events\ChatMessageSent;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ChatController extends Controller
{
    public function index(Order $order): JsonResponse
    {
        if (auth()->id() !== $order->user_id && auth()->id() !== $order->technician_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $messages = $order->chatMessages()->with('sender:id,name')->orderBy('created_at', 'asc')->paginate(50);

        return response()->json([
            'data' => $messages->items(),
            'current_page' => $messages->currentPage(),
            'last_page' => $messages->lastPage(),
            'total' => $messages->total(),
        ]);
    }

    public function store(Request $request, Order $order): JsonResponse
    {
        if (auth()->id() !== $order->user_id && auth()->id() !== $order->technician_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'message'   => 'nullable|string|max:1000',
            'image_url' => 'nullable|string|max:1024',
        ]);

        if (empty($request->message) && empty($request->image_url)) {
            return response()->json(['message' => 'Message or image is required.'], 422);
        }

        $message = $order->chatMessages()->create([
            'sender_id' => auth()->id(),
            'message'   => $request->message,
            'image_url' => $request->image_url,
            'is_read'   => false,
        ]);

        broadcast(new ChatMessageSent($message))->toOthers();

        return response()->json([
            'message' => __('messages.message_sent', [], app()->getLocale() ?? 'en'),
            'data' => $message->load('sender:id,name'),
        ], 201);
    }

    public function presignedUrl(Request $request): JsonResponse
    {
        $request->validate([
            'file_name' => 'required|string|max:255',
            'file_type' => 'required|string|max:100',
            'folder'    => 'nullable|string|max:100',
        ]);

        $folder = $request->folder ?: 'chat_media';
        $fileName = time() . '_' . preg_replace('/[^a-zA-Z0-9_\.-]/', '', $request->file_name);
        $path = $folder . '/' . $fileName;

        try {
            if (config('filesystems.default') === 's3') {
                $uploadUrl = Storage::disk('s3')->temporaryUploadUrl(
                    $path,
                    now()->addMinutes(15),
                    ['ContentType' => $request->file_type]
                );
                $fileUrl = Storage::disk('s3')->url($path);
                return response()->json([
                    'upload_url' => $uploadUrl,
                    'file_url'   => $fileUrl,
                    'file_path'  => $path,
                    'method'     => 'PUT',
                ]);
            }
        } catch (\Exception $e) {
            // Fall through to local fallback if S3 fails or is unconfigured in dev
        }

        return response()->json([
            'upload_url' => url('/api/v1/general/media/upload-local?path=' . urlencode($path)),
            'file_url'   => url('/storage/' . $path),
            'file_path'  => $path,
            'method'     => 'POST',
        ]);
    }

    public function uploadLocal(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|max:51200',
        ]);

        $path = $request->query('path', 'chat_media/' . time() . '_' . $request->file('file')->getClientOriginalName());
        $request->file('file')->storeAs(dirname($path), basename($path), 'public');

        return response()->json([
            'message'  => 'Uploaded locally',
            'file_url' => url('/storage/' . $path),
            'file_path'=> $path,
        ]);
    }
}

