import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ifix_client/core/services/reverb_client.dart';
import 'package:ifix_client/features/orders/ui/screens/chat_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final int orderId;
  final String technicianName;
  final String technicianPhone;
  final double initialLat;
  final double initialLng;
  final double customerLat;
  final double customerLng;

  const LiveTrackingScreen({
    super.key,
    required this.orderId,
    required this.technicianName,
    required this.technicianPhone,
    this.initialLat = 24.7136,
    this.initialLng = 46.6753,
    this.customerLat = 24.7200,
    this.customerLng = 46.6800,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  late double _techLat;
  late double _techLng;
  double _techHeading = 0.0;
  bool _isConnected = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _techLat = widget.initialLat;
    _techLng = widget.initialLng;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initReverb();
  }

  void _initReverb() {
    final client = ReverbClient.instance;
    client.connect();
    client.subscribe('private-order.${widget.orderId}');

    _isConnected = client.isConnected;

    client.on('App\\Events\\TechnicianLocationUpdated', _onLocationUpdated);
    client.on('TechnicianLocationUpdated', _onLocationUpdated);
  }

  void _onLocationUpdated(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      _isConnected = ReverbClient.instance.isConnected;
      if (data['lat'] != null && data['lng'] != null) {
        _techLat = (data['lat'] as num).toDouble();
        _techLng = (data['lng'] as num).toDouble();
      }
      if (data['heading'] != null) {
        _techHeading = (data['heading'] as num).toDouble();
      }
    });
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Earth radius in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  int _calculateEtaMinutes(double distanceKm) {
    // Assuming average city speed of 30 km/h (0.5 km/min)
    final mins = (distanceKm / 0.5).round();
    return mins < 1 ? 1 : mins;
  }

  @override
  void dispose() {
    ReverbClient.instance.off('App\\Events\\TechnicianLocationUpdated', _onLocationUpdated);
    ReverbClient.instance.off('TechnicianLocationUpdated', _onLocationUpdated);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = _calculateDistanceKm(_techLat, _techLng, widget.customerLat, widget.customerLng);
    final etaMins = _calculateEtaMinutes(distanceKm);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Live Tracking #${widget.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isConnected ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? const Color(0xFF16A34A) : const Color(0xFFCA8A04),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? 'Live (Reverb)' : 'Reconnecting...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isConnected ? const Color(0xFF16A34A) : const Color(0xFFCA8A04),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Visual Tracking Map Radar / Interactive Canvas
          Positioned.fill(
            child: CustomPaint(
              painter: _RadarMapPainter(
                techLat: _techLat,
                techLng: _techLng,
                customerLat: widget.customerLat,
                customerLng: widget.customerLng,
                heading: _techHeading,
                pulseValue: _pulseController.value,
              ),
            ),
          ),

          // Top Info Banner
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('EST. TIME', '~$etaMins mins', Icons.timer_outlined, const Color(0xFF2563EB)),
                  Container(height: 30, width: 1, color: Colors.grey.shade300),
                  _buildMetricItem('DISTANCE', '${distanceKm.toStringAsFixed(1)} km', Icons.directions_car_filled_outlined, const Color(0xFF16A34A)),
                  Container(height: 30, width: 1, color: Colors.grey.shade300),
                  _buildMetricItem('STATUS', 'On The Way', Icons.verified_outlined, const Color(0xFF9333EA)),
                ],
              ),
            ),
          ),

          // Bottom Technician Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: const Icon(Icons.person, size: 32, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.technicianName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Assigned Technician • Verified 🛠️',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Call logic
                          },
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFF6FF),
                            foregroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  orderId: widget.orderId,
                                  recipientName: widget.technicianName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _RadarMapPainter extends CustomPainter {
  final double techLat;
  final double techLng;
  final double customerLat;
  final double customerLng;
  final double heading;
  final double pulseValue;

  _RadarMapPainter({
    required this.techLat,
    required this.techLng,
    required this.customerLat,
    required this.customerLng,
    required this.heading,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);

    // Draw grid lines for map feel
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw radar circles around customer (home)
    final radarPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.15 * (1 - pulseValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 40 + (60 * pulseValue), radarPaint);

    final radarStroke = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 60, radarStroke);
    canvas.drawCircle(center, 120, radarStroke);

    // Customer icon (center)
    final homePaint = Paint()..color = const Color(0xFF16A34A);
    canvas.drawCircle(center, 14, homePaint);
    final whiteBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 14, whiteBorder);

    // Tech icon offset (simulated relative projection)
    final dLat = techLat - customerLat;
    final dLng = techLng - customerLng;
    final techOffset = Offset(
      center.dx + (dLng * 8000).clamp(-size.width / 2.2, size.width / 2.2),
      center.dy - (dLat * 8000).clamp(-size.height / 3, size.height / 3),
    );

    // Draw connection dashed line
    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(center, techOffset, linePaint);

    // Tech vehicle icon
    final techPaint = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(techOffset, 16, techPaint);
    canvas.drawCircle(techOffset, 16, whiteBorder);
  }

  @override
  bool shouldRepaint(covariant _RadarMapPainter oldDelegate) => true;
}
