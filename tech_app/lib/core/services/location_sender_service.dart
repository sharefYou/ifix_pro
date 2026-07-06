import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ifix_tech/core/api/dio_factory.dart';
import 'package:ifix_tech/core/services/reverb_client.dart';

class LocationSenderService {
  static final LocationSenderService instance = LocationSenderService._internal();
  LocationSenderService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _fallbackTimer;
  int? _activeOrderId;
  bool _isTracking = false;
  DateTime? _lastSentTime;

  bool get isTracking => _isTracking;
  int? get activeOrderId => _activeOrderId;

  Future<bool> startTracking(int orderId) async {
    if (_isTracking && _activeOrderId == orderId) return true;
    
    _activeOrderId = orderId;
    _isTracking = true;

    // Check permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) print('[LocationSender] Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) print('[LocationSender] Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) print('[LocationSender] Location permissions are permanently denied.');
      return false;
    }

    // Connect ReverbClient if not connected
    if (!ReverbClient.instance.isConnected) {
      ReverbClient.instance.connect();
    }
    ReverbClient.instance.subscribe('private-order.$orderId');

    // Start stream listening with distance filter of 10 meters
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _sendLocationUpdate(position);
      },
      onError: (e) {
        if (kDebugMode) print('[LocationSender] Stream error: $e');
      },
    );

    // Also start a fallback periodic timer (every 10 seconds) in case technician is stationary or stream pauses
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!_isTracking || _activeOrderId == null) return;
      try {
        final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        _sendLocationUpdate(position);
      } catch (e) {
        if (kDebugMode) print('[LocationSender] Fallback get position error: $e');
      }
    });

    if (kDebugMode) print('[LocationSender] Started tracking for order #$orderId');
    return true;
  }

  Future<void> _sendLocationUpdate(Position position) async {
    if (!_isTracking || _activeOrderId == null) return;

    // Throttle: do not send more often than once every 4 seconds
    final now = DateTime.now();
    if (_lastSentTime != null && now.difference(_lastSentTime!).inSeconds < 4) {
      return;
    }
    _lastSentTime = now;

    try {
      final dio = await DioFactory.getDio(customBaseUrl: 'https://sharef.alwaysdata.net');
      final response = await dio.post(
        '/api/v1/technician/tracking/broadcast',
        data: {
          'lat': position.latitude,
          'lng': position.longitude,
          'heading': position.heading,
          'order_id': _activeOrderId,
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[LocationSender] Broadcasted location: (${position.latitude}, ${position.longitude}) for Order #$_activeOrderId');
        }
      }
    } catch (e) {
      if (kDebugMode) print('[LocationSender] Broadcast error: $e');
      // If network drops, ReverbClient exponential backoff will handle reconnection
    }
  }

  void stopTracking() {
    _isTracking = false;
    _activeOrderId = null;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    if (kDebugMode) print('[LocationSender] Stopped tracking.');
  }
}
