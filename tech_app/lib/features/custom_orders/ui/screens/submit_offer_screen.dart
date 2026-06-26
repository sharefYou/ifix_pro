import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ifix_button.dart';
import '../../../../core/widgets/ifix_card.dart';
import '../../../../core/widgets/ifix_text_field.dart';

class SubmitOfferScreen extends StatefulWidget {
  final int orderId;

  const SubmitOfferScreen({super.key, required this.orderId});

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  final _priceCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_priceCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تقديم عرضك بنجاح، بانتظار رد العميل', style: TextStyle(fontFamily: 'Cairo'))),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم عرض سعر'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Summary
            IFixCard(
              color: AppColors.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('وصف طلب العميل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
                  Text(
                    'أحتاج إصلاح تسريب في الحمام الرئيسي وتغيير الصنبور بالكامل، المشكلة مستمرة منذ يومين...',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: 'عرضك المالي'),
            const SizedBox(height: 12),
            IFixTextField(
              hint: 'أدخل السعر الإجمالي',
              label: 'السعر (ريال)',
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.payments_rounded, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '* سيتم خصم عمولة التطبيق (15%) من هذا المبلغ',
              style: AppTextStyles.caption.copyWith(color: AppColors.gold),
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: 'رسالة للعميل (اختياري)'),
            const SizedBox(height: 12),
            IFixTextField(
              hint: 'اكتب تفاصيل عن عرضك أو موعد وصولك المتوقع...',
              controller: _messageCtrl,
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            IFixButton(
              label: 'إرسال العرض',
              onTap: _onSubmit,
              isLoading: _loading,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
