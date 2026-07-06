import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/services/reverb_client.dart';

class ChatScreen extends StatefulWidget {
  final int orderId;
  final String recipientName;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.recipientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _initReverbListener();
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await DioHelper.getData(endPoint: '/api/v1/general/orders/\${widget.orderId}/chat');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final List items = res.data['data'];
        setState(() {
          _messages.clear();
          for (var item in items) {
            _messages.add(Map<String, dynamic>.from(item));
          }
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (kDebugMode) print('[ChatScreen] Fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initReverbListener() {
    final client = ReverbClient.instance;
    client.connect();
    client.subscribe('private-order.\${widget.orderId}');

    client.on('App\\Events\\ChatMessageSent', _onMessageReceived);
    client.on('ChatMessageSent', _onMessageReceived);
  }

  void _onMessageReceived(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      _messages.add(data);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    _messageController.clear();

    try {
      final res = await DioHelper.postData(
        endPoint: '/api/v1/general/orders/\${widget.orderId}/chat',
        data: {
          if (text.isNotEmpty) 'message': text,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      if (res.statusCode == 201 && res.data['data'] != null) {
        setState(() {
          _messages.add(Map<String, dynamic>.from(res.data['data']));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (kDebugMode) print('[ChatScreen] Send error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message. Please check your connection.')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    setState(() => _isUploadingImage = true);

    try {
      // Step 1: Request Presigned URL from Laravel
      final presignedRes = await DioHelper.postData(
        endPoint: '/api/v1/general/media/presigned-url',
        data: {
          'file_name': image.name,
          'file_type': 'image/jpeg',
          'folder': 'chat_media',
        },
      );

      if (presignedRes.statusCode == 200 && presignedRes.data != null) {
        final uploadUrl = presignedRes.data['upload_url'];
        final fileUrl = presignedRes.data['file_url'];
        final method = presignedRes.data['method'];
        final filePath = presignedRes.data['file_path'];

        final Uint8List fileBytes = await image.readAsBytes();

        // Step 2: Upload directly to S3 (PUT) or fallback to local (POST)
        if (method == 'PUT') {
          await Dio().put(
            uploadUrl,
            data: Stream.fromIterable([fileBytes]),
            options: Options(
              headers: {
                'Content-Type': 'image/jpeg',
                'Content-Length': fileBytes.length.toString(),
              },
            ),
          );
        } else {
          // Local fallback upload
          final formData = FormData.fromMap({
            'file': MultipartFile.fromBytes(fileBytes, filename: image.name),
          });
          await DioHelper.postData(
            endPoint: '/api/v1/general/media/upload-local?path=${Uri.encodeComponent(filePath)}',
            data: formData,
          );
        }

        // Step 3: Send chat message with Direct-to-S3 image_url
        await _sendMessage(imageUrl: fileUrl);
      }
    } catch (e) {
      if (kDebugMode) print('[ChatScreen] Direct-to-S3 Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  void dispose() {
    ReverbClient.instance.off('App\\Events\\ChatMessageSent', _onMessageReceived);
    ReverbClient.instance.off('ChatMessageSent', _onMessageReceived);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEFF6FF),
              child: const Icon(Icons.person, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipientName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const Text(
                  '🟢 Online • Reverb Secure Chat',
                  style: TextStyle(fontSize: 11, color: Color(0xFF16A34A)),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet. Start conversation with \${widget.recipientName}!',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          // Simple check: if sender is customer or technician
                          final isMe = msg['sender'] != null && msg['sender']['name'] != widget.recipientName;
                          final text = msg['message'] as String?;
                          final imageUrl = msg['image_url'] as String?;
                          final time = msg['created_at'] != null && msg['created_at'].toString().length >= 16
                              ? msg['created_at'].toString().substring(11, 16)
                              : '';

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF2563EB) : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        placeholder: (context, url) => Container(
                                          height: 150,
                                          color: Colors.grey.shade200,
                                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          height: 150,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    if (text != null && text.isNotEmpty) const SizedBox(height: 8),
                                  ],
                                  if (text != null && text.isNotEmpty)
                                    Text(
                                      text,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : const Color(0xFF1E293B),
                                        fontSize: 15,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        color: isMe ? Colors.blue.shade100 : const Color(0xFF94A3B8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          if (_isUploadingImage)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFEFF6FF),
              child: const Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Uploading image directly to cloud (Presigned URL)...', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB))),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                    icon: const Icon(Icons.image_outlined, color: Color(0xFF2563EB), size: 26),
                    tooltip: 'Send Image',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF2563EB),
                    child: IconButton(
                      onPressed: () => _sendMessage(),
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
