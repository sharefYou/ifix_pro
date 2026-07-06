import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ifix_client/core/api/dio_helper.dart';

class ReverbClient {
  static final ReverbClient instance = ReverbClient._internal();
  ReverbClient._internal();

  final String defaultWsUrl = 'ws://sharef.alwaysdata.net:8080/app/ifix_key?protocol=7&client=dart&version=1.0.0&flash=false';
  
  WebSocketChannel? _channel;
  String? _socketId;
  int _reconnectDelay = 1;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  bool _isConnected = false;
  
  final Map<String, List<Function(Map<String, dynamic>)>> _eventListeners = {};
  final Set<String> _subscribedChannels = {};

  bool get isConnected => _isConnected;

  void connect({String? wsUrl}) {
    if (_isDisposed) _isDisposed = false;
    if (_channel != null && _isConnected) return;
    
    final url = wsUrl ?? defaultWsUrl;
    try {
      if (kDebugMode) print('[ReverbClient] Connecting to $url...');
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (message) {
          _onMessage(message);
        },
        onDone: _onDisconnect,
        onError: (error) {
          if (kDebugMode) print('[ReverbClient] Error: $error');
          _onDisconnect();
        },
      );
    } catch (e) {
      if (kDebugMode) print('[ReverbClient] Connection exception: $e');
      _onDisconnect();
    }
  }

  void _onDisconnect() {
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
    _socketId = null;
    
    if (_isDisposed || (_reconnectTimer?.isActive ?? false)) return;
    
    if (kDebugMode) {
      print('[ReverbClient] Disconnected. Reconnecting in $_reconnectDelay seconds (Exponential Backoff)...');
    }
    
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      if (_isDisposed) return;
      _reconnectDelay = (_reconnectDelay * 2).clamp(1, 30); // Double delay up to 30s max
      connect();
    });
  }

  void _onMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message.toString());
      final String? event = data['event'];
      
      if (event == 'pusher:connection_established') {
        _isConnected = true;
        _reconnectDelay = 1; // Reset exponential backoff on success
        final Map<String, dynamic> payload = jsonDecode(data['data']);
        _socketId = payload['socket_id'];
        if (kDebugMode) print('[ReverbClient] Connected! Socket ID: $_socketId');
        
        for (final channelName in _subscribedChannels) {
          _subscribeToChannel(channelName);
        }
      } else if (event == 'pusher:ping') {
        _send({'event': 'pusher:pong', 'data': {}});
      } else if (event != null) {
        final channel = data['channel'];
        final dynamic rawData = data['data'];
        Map<String, dynamic> parsedData = {};
        if (rawData is String) {
          try { parsedData = jsonDecode(rawData); } catch (_) { parsedData = {'message': rawData}; }
        } else if (rawData is Map) {
          parsedData = Map<String, dynamic>.from(rawData);
        }
        
        final listeners = _eventListeners[event] ?? [];
        for (final listener in listeners) {
          listener(parsedData);
        }
        // Also trigger generic listeners matching channel name + event
        if (channel != null) {
          final channelListeners = _eventListeners['$channel:$event'] ?? [];
          for (final listener in channelListeners) {
            listener(parsedData);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('[ReverbClient] Parse error: $e');
    }
  }

  Future<void> subscribe(String channelName) async {
    _subscribedChannels.add(channelName);
    if (_socketId != null && _isConnected) {
      await _subscribeToChannel(channelName);
    } else {
      connect();
    }
  }

  Future<void> unsubscribe(String channelName) async {
    _subscribedChannels.remove(channelName);
    if (_isConnected) {
      _send({
        'event': 'pusher:unsubscribe',
        'data': {'channel': channelName}
      });
    }
  }

  Future<void> _subscribeToChannel(String channelName) async {
    if (_socketId == null) return;
    if (channelName.startsWith('private-') || channelName.startsWith('presence-')) {
      try {
        final response = await DioHelper.postData(
          endPoint: '/api/broadcasting/auth',
          data: {
            'socket_id': _socketId,
            'channel_name': channelName,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          final authData = response.data;
          _send({
            'event': 'pusher:subscribe',
            'data': {
              'channel': channelName,
              'auth': authData['auth'],
              if (authData['channel_data'] != null) 'channel_data': authData['channel_data'],
            }
          });
          if (kDebugMode) print('[ReverbClient] Subscribed to private channel: $channelName');
        }
      } catch (e) {
        if (kDebugMode) print('[ReverbClient] Channel auth failed for $channelName: $e');
      }
    } else {
      _send({
        'event': 'pusher:subscribe',
        'data': {'channel': channelName}
      });
      if (kDebugMode) print('[ReverbClient] Subscribed to public channel: $channelName');
    }
  }

  void on(String eventName, Function(Map<String, dynamic>) listener) {
    _eventListeners.putIfAbsent(eventName, () => []).add(listener);
  }

  void off(String eventName, [Function(Map<String, dynamic>)? listener]) {
    if (listener == null) {
      _eventListeners.remove(eventName);
    } else {
      _eventListeners[eventName]?.remove(listener);
    }
  }

  void _send(Map<String, dynamic> payload) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(payload));
    }
  }

  void dispose() {
    _isDisposed = true;
    _isConnected = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _eventListeners.clear();
    _subscribedChannels.clear();
  }
}
