import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_button.dart';
import '../../../../core/widgets/ifix_card.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double debt = 450.0;
    const double limit = 500.0;
    const bool isNearLimit = debt >= limit * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة المالية'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
        child: Column(
          children: [
            // Balance Card
            _buildBalanceCard(),
            const SizedBox(height: 24),

            // Debt Card
            _buildDebtCard(debt, limit, isNearLimit, context),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: _WalletAction(
                    icon: Icons.account_balance_rounded,
                    label: 'طلب تحويل',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WalletAction(
                    icon: Icons.receipt_long_rounded,
                    label: 'كشف حساب',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: 'آخر العمليات'),
            const SizedBox(height: 12),
            ...List.generate(5, (i) => _TransactionItem(
              title: i % 2 == 0 ? 'ربح من طلب #10$i' : 'سداد مديونية',
              amount: i % 2 == 0 ? 120.0 : -300.0,
              date: '13 مايو 2026',
              isEarning: i % 2 == 0,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text('إجمالي أرباحك', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '3,450 ل.س',
            style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Text('متاح للتحويل: 1,200 ل.س', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(double debt, double limit, bool isNearLimit, BuildContext context) {
    return IFixCard(
      color: isNearLimit ? AppColors.error.withValues(alpha: 0.05) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مديونية التطبيق', style: AppTextStyles.headlineSmall),
              Text('$debt / $limit ل.س', style: AppTextStyles.labelLarge.copyWith(color: isNearLimit ? AppColors.error : AppColors.gold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: debt / limit,
            backgroundColor: AppColors.border,
            color: isNearLimit ? AppColors.error : AppColors.gold,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            isNearLimit 
              ? 'تنبيه: لقد اقتربت من حد المديونية. يرجى السداد لتجنب إيقاف الحساب.' 
              : 'هذه هي المبالغ المستحقة للتطبيق من العمليات النقدية.',
            style: AppTextStyles.bodySmall.copyWith(color: isNearLimit ? AppColors.error : AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IFixButton(
                  label: 'رفع إيصال سداد',
                  height: 40,
                  color: AppColors.gold,
                  onTap: () => context.push(AppRoutes.uploadReceipt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('بيانات البنك', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WalletAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IFixCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 26),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final bool isEarning;

  const _TransactionItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.isEarning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isEarning ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarning ? Icons.add_rounded : Icons.remove_rounded,
              color: isEarning ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(date, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            '${isEarning ? '+' : ''}$amount ل.س',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isEarning ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
