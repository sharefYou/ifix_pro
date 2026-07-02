import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/ifix_button.dart';
import '../../../../core/widgets/ifix_card.dart';
import '../../../../core/widgets/ifix_text_field.dart';

class UploadReceiptScreen extends StatefulWidget {
  const UploadReceiptScreen({super.key});

  @override
  State<UploadReceiptScreen> createState() => _UploadReceiptScreenState();
}

class _UploadReceiptScreenState extends State<UploadReceiptScreen> {
  final _amountCtrl = TextEditingController();
  String? _receiptPath;
  bool _loading = false;
  final _picker = ImagePicker();

  Future<void> _pickReceipt() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _receiptPath = img.path);
  }

  void _onUpload() async {
    if (_amountCtrl.text.isEmpty || _receiptPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المبلغ ورفع صورة الإيصال', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع الإيصال بنجاح، سيتم تحديث رصيدك بعد المراجعة', style: TextStyle(fontFamily: 'Cairo'))),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع إيصال سداد'),
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
            // Bank Info Card
            IFixCard(
              color: AppColors.accent.withValues(alpha: 0.1),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بيانات الحساب البنكي للتطبيق:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo')),
                  SizedBox(height: 8),
                  Text('بنك الشام (Cham Bank)', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  Text('IBAN: SY12 0011 2233 4455 6677 8899', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('باسم: شركة آي فيكس لخدمات الصيانة والتقنية', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: 'بيانات الحوالة'),
            const SizedBox(height: 12),
            IFixTextField(
              hint: 'أدخل المبلغ المحول',
              label: 'المبلغ (ريال)',
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.payments_rounded, size: 20),
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: 'صورة الإيصال'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickReceipt,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(
                    color: _receiptPath != null ? AppColors.success : AppColors.border,
                    width: _receiptPath != null ? 1.5 : 0.5,
                  ),
                ),
                child: _receiptPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                        child: const Center(child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64)),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded, color: AppColors.accent, size: 48),
                          SizedBox(height: 12),
                          Text('اضغط هنا لرفع صورة الإيصال', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            IFixButton(
              label: 'إرسال للمراجعة',
              onTap: _onUpload,
              isLoading: _loading,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
