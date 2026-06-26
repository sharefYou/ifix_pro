import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ifix_tech/features/orders/logic/order_cubit.dart';
import 'package:ifix_tech/core/constants/app_colors.dart';
import 'package:ifix_tech/core/constants/app_constants.dart';
import 'package:ifix_tech/core/constants/app_text_styles.dart';
import 'package:ifix_tech/core/widgets/ifix_button.dart';
import 'package:ifix_tech/core/widgets/ifix_card.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic>? orderData;

  const OrderDetailsScreen({super.key, required this.orderId, this.orderData});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _accepted = false;

  void _onAccept() {
    context.read<OrderCubit>().acceptOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData ?? {};
    final total = double.tryParse(order['total_price']?.toString() ?? '0') ?? 0;
    final commission = total * 0.15;
    final net = total - commission;

    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderActionSuccess) {
          setState(() => _accepted = true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo'))));
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo'))));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
          leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_rounded)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_accepted)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.radiusMD), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text('تم قبول الطلب، توجه للعميل الآن', style: AppTextStyles.labelLarge.copyWith(color: AppColors.success)),
                  ]),
                ),
              Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppConstants.radiusLG), border: Border.all(color: AppColors.border)),
                child: const Stack(alignment: Alignment.center, children: [Icon(Icons.map_rounded, color: AppColors.textSecondary, size: 64)]),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'بيانات العميل'),
              const SizedBox(height: 12),
              IFixCard(child: Row(children: [
                const CircleAvatar(radius: 24, backgroundColor: AppColors.surfaceVariant, child: Icon(Icons.person_rounded, color: AppColors.accent)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(order['customer']?['name'] ?? 'عميل', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
                  Text(order['address_name'] ?? 'الموقع غير محدد', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Cairo')),
                ])),
                if (_accepted) IconButton(onPressed: () {}, icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.success)),
              ])),
              const SizedBox(height: 24),
              const SectionHeader(title: 'الخدمة المطلوبة'),
              const SizedBox(height: 12),
              IFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order['service']?['name_ar'] ?? 'خدمة صيانة', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 8),
                Text('وقت الزيارة: ${order['scheduled_at'] ?? 'فوري'}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent)),
              ])),
              const SizedBox(height: 24),
              const SectionHeader(title: 'الملخص المالي'),
              const SizedBox(height: 12),
              IFixCard(child: Column(children: [
                _PriceRow('إجمالي السعر', '$total ل.س'),
                _PriceRow('عمولة التطبيق (15%)', '-$commission ل.س'),
                const Divider(height: 24),
                _PriceRow('صافي الربح', '$net ل.س', isBold: true, color: AppColors.success),
              ])),
              const SizedBox(height: 32),
              if (!_accepted)
                Row(children: [
                  Expanded(child: BlocBuilder<OrderCubit, OrderState>(
                    builder: (context, state) {
                      return IFixButton(label: 'قبول الطلب', onTap: _onAccept, isLoading: state is OrderActionLoading);
                    },
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: IFixButton(label: 'رفض', isOutlined: true, color: AppColors.error, onTap: () => context.pop())),
                ])
              else
                IFixButton(label: 'تم الوصول للموقع', onTap: () {}),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? color;
  const _PriceRow(this.label, this.value, {this.isBold = false, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : null)),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: isBold ? FontWeight.bold : null, color: color ?? (isBold ? AppColors.textPrimary : AppColors.textSecondary))),
      ]),
    );
  }
}
