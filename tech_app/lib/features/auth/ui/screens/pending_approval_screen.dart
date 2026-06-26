import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_button.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.timer_outlined, color: AppColors.gold, size: 64),
              ),
              const SizedBox(height: 40),
              Text('طلبك قيد المراجعة', style: AppTextStyles.displayMedium),
              const SizedBox(height: 16),
              Text(
                'شكراً لانضمامك إلى iFix! فريقنا يقوم الآن بمراجعة بياناتك والوثائق المرفوعة. سيتم تفعيل حسابك خلال 24 ساعة كحد أقصى.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              IFixButton(
                label: 'تحديث الحالة',
                onTap: () {
                  // Simulate refresh
                  context.go(AppRoutes.login);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.welcome),
                child: const Text('العودة للرئيسية', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
