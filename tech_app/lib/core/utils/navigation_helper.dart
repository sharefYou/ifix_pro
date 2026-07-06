import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ifix_tech/core/constants/app_colors.dart';

class NavigationHelper {
  static String calculateDistanceKm(Map<String, dynamic> order, {double techLat = 24.7136, double techLng = 46.6753}) {
    if (order['distance'] != null) {
      final dist = double.tryParse(order['distance'].toString());
      if (dist != null) {
        return '${dist.toStringAsFixed(1)} كم';
      }
    }
    final custLat = double.tryParse(order['user']?['lat']?.toString() ?? '') ?? 24.7136;
    final custLng = double.tryParse(order['user']?['lng']?.toString() ?? '') ?? 46.6753;
    final meters = Geolocator.distanceBetween(techLat, techLng, custLat, custLng);
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} كم';
  }

  static Future<void> launchNavigation(BuildContext context, double? lat, double? lng, {String? customerName}) async {
    final targetLat = lat ?? 24.7136;
    final targetLng = lng ?? 46.6753;

    final googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$targetLat,$targetLng');
    final wazeUrl = Uri.parse('https://waze.com/ul?ll=$targetLat,$targetLng&navigate=yes');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.explore_rounded, color: AppColors.accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customerName != null ? 'توجيه المسار إلى $customerName' : 'اختر تطبيق الملاحة والتوجيه 🧭',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر التطبيق المفضل لديك لبدء التوجيه الصوتي وتتبع حركة المرور:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Cairo'),
              ),
              const Divider(height: 32, color: AppColors.border),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.map_rounded, color: Color(0xFF3B82F6), size: 28),
                ),
                title: const Text('خرائط جوجل (Google Maps)', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                subtitle: const Text('توجيه مباشر وحساب الزحام المروري', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo', fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                onTap: () async {
                  Navigator.pop(context);
                  if (await canLaunchUrl(googleMapsUrl)) {
                    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح خرائط جوجل', style: TextStyle(fontFamily: 'Cairo'))));
                  }
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.navigation_rounded, color: Color(0xFF10B981), size: 28),
                ),
                title: const Text('تطبيق وايز (Waze)', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                subtitle: const Text('تنبيهات الطريق والتوجيه الذكي السريع', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo', fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                onTap: () async {
                  Navigator.pop(context);
                  if (await canLaunchUrl(wazeUrl)) {
                    await launchUrl(wazeUrl, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق Waze', style: TextStyle(fontFamily: 'Cairo'))));
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
