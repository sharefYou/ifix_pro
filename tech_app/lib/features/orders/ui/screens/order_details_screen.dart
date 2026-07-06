import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ifix_tech/features/orders/logic/order_cubit.dart';
import 'package:ifix_tech/core/constants/app_colors.dart';
import 'package:ifix_tech/core/constants/app_constants.dart';
import 'package:ifix_tech/core/constants/app_text_styles.dart';
import 'package:ifix_tech/core/widgets/ifix_button.dart';
import 'package:ifix_tech/core/widgets/ifix_card.dart';
import 'package:ifix_tech/core/utils/navigation_helper.dart';
import 'package:ifix_tech/core/routing/app_router.dart';
import 'chat_screen.dart';

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
                _PriceRow('إجمالي السعر', '$total ريال'),
                _PriceRow('عمولة التطبيق (15%)', '-$commission ريال'),
                const Divider(height: 24),
                _PriceRow('صافي الربح', '$net ريال', isBold: true, color: AppColors.success),
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
                IFixButton(
                  label: 'إتمام الزيارة وقائمة الفحص والتوقيع ✅',
                  color: AppColors.accent,
                  onTap: () => context.push(
                    AppRoutes.orderChecklist,
                    extra: {
                      'orderId': widget.orderId,
                      'serviceName': order['service']?['name_ar'] ?? 'صيانة عامة',
                      'customerName': order['customer']?['name'] ?? 'العميل',
                      'totalPrice': double.tryParse(order['total_price']?.toString() ?? '0')?.toInt() ?? 0,
                    },
                  ),
                ),
              if (_accepted || order['status'] == 'accepted' || order['status'] == 'in_progress' || order['status'] == 'on_the_way') ...[
                const SizedBox(height: 16),
                IFixButton(
                  label: 'بدء التوجيه (Google Maps / Waze) 🧭',
                  color: AppColors.success,
                  onTap: () => NavigationHelper.launchNavigation(
                    context,
                    double.tryParse(order['user']?['lat']?.toString() ?? ''),
                    double.tryParse(order['user']?['lng']?.toString() ?? ''),
                    customerName: order['customer']?['name'] ?? 'العميل',
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: IFixButton(
                      label: 'محادثة العميل',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(orderId: widget.orderId, recipientName: order['customer']?['name'] ?? 'العميل'))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: IFixButton(
                      label: 'زر الطوارئ SOS',
                      color: AppColors.error,
                      onTap: () => _triggerSosAlert(context, widget.orderId),
                    ),
                  ),
                ]),
              ],
              if (order['status'] == 'completed') ...[
                const SizedBox(height: 16),
                IFixButton(
                  label: 'عرض الفاتورة',
                  onTap: () => _showInvoiceModal(context, order),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _triggerSosAlert(BuildContext context, int orderId) async {
    try {
      final res = await Dio().post(
        'https://sharef.alwaysdata.net/api/v1/general/sos/alert',
        data: {
          'order_id': orderId,
          'lat': 24.7136,
          'lng': 46.6753,
          'reason': 'safety_threat',
        },
      );
      if (res.statusCode == 201 && context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surfaceVariant,
            title: const Row(children: [Icon(Icons.warning, color: AppColors.error), SizedBox(width: 8), Text('تم إرسال بلاغ الطوارئ!', style: TextStyle(fontFamily: 'Cairo'))]),
            content: const Text('تم إبلاغ الإدارة وفريق التدخل السريع بموقعك الحالي وحالة الطوارئ.', style: TextStyle(fontFamily: 'Cairo')),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo')))],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء إرسال بلاغ الطوارئ', style: TextStyle(fontFamily: 'Cairo'))));
      }
    }
  }

  void _showInvoiceModal(BuildContext context, Map<String, dynamic> order) {
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
              const Text('فاتورة ضريبية مبسطة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const Divider(height: 32),
              _PriceRow('رقم الطلب', '#${order['id'] ?? widget.orderId}'),
              _PriceRow('الخدمة', order['service']?['name_ar'] ?? 'صيانة عامة'),
              _PriceRow('الإجمالي', '${order['total_price'] ?? 0} ريال', isBold: true, color: AppColors.success),
              const SizedBox(height: 24),
              IFixButton(label: 'إغلاق', onTap: () => Navigator.pop(context)),
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
