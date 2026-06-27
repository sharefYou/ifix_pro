import 'package:flutter/material.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../../orders/ui/screens/create_order_screen.dart';
import '../../data/models/service_model.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;
  const ServiceDetailsScreen({super.key, required this.service});

  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: const BackButton(color: textColor),
          title: const Text(
            'تفاصيل الخدمة',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tertiaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () => context.push(CreateOrderScreen(service: service)),
                child: const Text(
                  'حجز وطلب صيانة الآن',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: service.image != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(service.image!, width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.home_repair_service, size: 80, color: tertiaryColor.withValues(alpha: 0.8)))))
                    : Center(
                        child: Icon(Icons.home_repair_service, size: 80, color: tertiaryColor.withValues(alpha: 0.8)),
                      ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: tertiaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${service.price} ريال',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tertiaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'وصف الخدمة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                service.description.isNotEmpty
                    ? service.description
                    : 'تشمل هذه الخدمة فحص وصيانة شاملة بأعلى معايير الجودة مع ضمان على الصيانة.',
                style: TextStyle(fontSize: 15, height: 1.6, color: textColor.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 32),
              _buildFeatureRow(Icons.verified, 'ضمان على الخدمة لمدة 30 يوماً'),
              const SizedBox(height: 12),
              _buildFeatureRow(Icons.schedule, 'حجز مرن حسب الوقت المناسب لك'),
              const SizedBox(height: 12),
              _buildFeatureRow(Icons.engineering, 'فنيون معتمدون وذوو خبرة عالية'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: tertiaryColor, size: 22),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }
}
