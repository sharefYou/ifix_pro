import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_card.dart';

class CustomOrdersListScreen extends StatelessWidget {
  const CustomOrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات الخاصة'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _CustomOrderListItem(
          id: i + 1,
          description: 'أحتاج إصلاح تسريب في الحمام الرئيسي وتغيير الصنبور بالكامل، المشكلة مستمرة منذ يومين...',
          city: 'الرياض',
          date: 'منذ ساعتين',
          onTap: () => context.push(AppRoutes.submitOffer, extra: {'orderId': i + 1}),
        ),
      ),
    );
  }
}

class _CustomOrderListItem extends StatelessWidget {
  final int id;
  final String description;
  final String city;
  final String date;
  final VoidCallback onTap;

  const _CustomOrderListItem({
    required this.id,
    required this.description,
    required this.city,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IFixCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('طلب #$id', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent)),
              StatusChip(label: 'جديد', color: AppColors.gold, icon: Icons.new_releases_rounded),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.bodyLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(city, style: AppTextStyles.caption),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(date, style: AppTextStyles.caption),
              const Spacer(),
              Text(
                'قدم عرضك',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}
