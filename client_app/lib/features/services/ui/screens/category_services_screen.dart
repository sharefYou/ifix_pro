import 'package:flutter/material.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/service_model.dart';
import 'service_details_screen.dart';

class CategoryServicesScreen extends StatelessWidget {
  final ServiceCategoryModel category;

  const CategoryServicesScreen({super.key, required this.category});

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
          title: Text(category.name, style: const TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: textColor),
        ),
        body: category.services.isEmpty
            ? const Center(child: Text('لا توجد خدمات في هذا القسم حالياً', style: TextStyle(color: textColor, fontSize: 16)))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: category.services.length,
                itemBuilder: (context, idx) {
                  final service = category.services[idx];
                  return _buildServiceCard(context, service);
                },
              ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service) {
    return InkWell(
      onTap: () => context.push(ServiceDetailsScreen(service: service)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [BoxShadow(color: textColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: service.image != null
                  ? Image.network(service.image!, width: 28, height: 28, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.build_outlined, color: tertiaryColor, size: 28))
                  : const Icon(Icons.build_outlined, color: tertiaryColor, size: 28),
            ),
            const Spacer(),
            Text(
              service.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text('${service.price} ريال', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: tertiaryColor)),
          ],
        ),
      ),
    );
  }
}
