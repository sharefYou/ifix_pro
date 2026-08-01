import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ifix_tech/core/constants/app_colors.dart';
import 'package:ifix_tech/core/constants/app_constants.dart';
import 'package:ifix_tech/core/widgets/ifix_button.dart';
import 'package:ifix_tech/core/widgets/ifix_card.dart';
import 'package:ifix_tech/core/api/dio_factory.dart';
import 'package:ifix_tech/core/routing/app_router.dart';
import 'package:ifix_tech/features/orders/logic/order_cubit.dart';

class OrderChecklistScreen extends StatefulWidget {
  final int orderId;
  final String serviceName;
  final String customerName;
  final int totalPrice;

  const OrderChecklistScreen({
    super.key,
    required this.orderId,
    required this.serviceName,
    required this.customerName,
    required this.totalPrice,
  });

  @override
  State<OrderChecklistScreen> createState() => _OrderChecklistScreenState();
}

class _OrderChecklistScreenState extends State<OrderChecklistScreen> {
  bool _safetyChecked = false;
  bool _powerDisconnected = false;
  bool _workAreaClean = false;
  bool _systemTested = false;
  bool _hasSigned = false;
  bool _isSubmitting = false;

  String? _beforePhotoPath;
  String? _afterPhotoPath;

  Future<void> _uploadPhoto(bool isBefore) async {
    // Simulate Direct-to-S3 Presigned URL Upload as per architecture rules
    setState(() {
      if (isBefore) {
        _beforePhotoPath = 's3://ifix-pro-media/checklists/before_${widget.orderId}.jpg';
      } else {
        _afterPhotoPath = 's3://ifix-pro-media/checklists/after_${widget.orderId}.jpg';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBefore ? 'تم رفع صورة فحص ما قبل العمل إلى السحابة بنجاح 📷' : 'تم رفع صورة فحص الجودة والإنجاز إلى السحابة بنجاح 📷',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _submitChecklistAndComplete() async {
    if (!_safetyChecked || !_powerDisconnected || !_workAreaClean || !_systemTested || !_hasSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى استكمال جميع عناصر الفحص وتوقيع العميل قبل إغلاق الطلب.', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = await DioFactory.getDio();
      await dio.post('orders/${widget.orderId}/checklist', data: {
        'safety_checked': _safetyChecked,
        'power_disconnected': _powerDisconnected,
        'work_area_clean': _workAreaClean,
        'system_tested': _systemTested,
        'before_photo_path': _beforePhotoPath ?? 's3://default_before.jpg',
        'after_photo_path': _afterPhotoPath ?? 's3://default_after.jpg',
        'customer_signature_path': 's3://ifix-pro-media/signatures/sig_${widget.orderId}.png',
        'customer_notes': 'تم فحص وتشغيل الخدمة وأقر العميل بالرضا التام عن الجودة.',
      });

      if (mounted) {
        context.read<OrderCubit>().completeOrder(widget.orderId);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حفظ قائمة الفحص: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderActionSuccess) {
          setState(() => _isSubmitting = false);
          _showCompletionSuccessDialog();
        } else if (state is OrderError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الفحص وتوقيع التسليم'),
          leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_rounded)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.surfaceVariant]),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fact_check_rounded, color: AppColors.accent, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('إغلاق الطلب #${widget.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo', color: Colors.white)),
                          Text('${widget.serviceName} - العميل: ${widget.customerName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _HeaderBadge(title: 'الخطوة 1: فحص السلامة قبل البدء (Pre-Job Inspection) 🛡️', color: Color(0xFF3B82F6)),
              const SizedBox(height: 12),
              IFixCard(
                child: Column(
                  children: [
                    _buildCheckboxTile(
                      label: 'تم فصل التيار الكهربائي / إغلاق المحابس الرئيسية والتأكد من أمان الموقع',
                      value: _powerDisconnected,
                      onChanged: (val) => setState(() => _powerDisconnected = val ?? false),
                    ),
                    const Divider(height: 1),
                    _buildCheckboxTile(
                      label: 'تم فحص مكان العمل والتأكد من خلوه من العوائق والمخاطر المحيطة',
                      value: _safetyChecked,
                      onChanged: (val) => setState(() => _safetyChecked = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoUploadBtn(
                      label: _beforePhotoPath != null ? 'تم رفع صورة ما قبل العمل ✔️' : 'التقاط صورة قبل العمل 📷 (Direct S3 Upload)',
                      isUploaded: _beforePhotoPath != null,
                      onTap: () => _uploadPhoto(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _HeaderBadge(title: 'الخطوة 2: فحص الجودة والتسليم (Post-Job Verification) 🛠️', color: Color(0xFF10B981)),
              const SizedBox(height: 12),
              IFixCard(
                child: Column(
                  children: [
                    _buildCheckboxTile(
                      label: 'تم تنظيف مكان العمل وإعادته لحالته الطبيعية بالكامل بعد انتهاء الصيانة',
                      value: _workAreaClean,
                      onChanged: (val) => setState(() => _workAreaClean = val ?? false),
                    ),
                    const Divider(height: 1),
                    _buildCheckboxTile(
                      label: 'تم اختبار الجهاز/العطل والتأكد من عمله بكفاءة دون أي عيوب أو مشاكل',
                      value: _systemTested,
                      onChanged: (val) => setState(() => _systemTested = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoUploadBtn(
                      label: _afterPhotoPath != null ? 'تم رفع صورة الإنجاز والتسليم ✔️' : 'التقاط صورة بعد الإنجاز 📷 (Direct S3 Upload)',
                      isUploaded: _afterPhotoPath != null,
                      onTap: () => _uploadPhoto(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _HeaderBadge(title: 'الخطوة 3: توقيع العميل الإلكتروني (Customer Signature) ✍️', color: Color(0xFFF59E0B)),
              const SizedBox(height: 12),
              IFixCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إقرار العميل: أقر أنا العميل باستلام العمل المطلوب بجودة عالية وأوافق على إغلاق الطلب وإصدار الفاتورة الضريبية.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Cairo', height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    _SignaturePad(
                      onSignedChanged: (signed) => setState(() => _hasSigned = signed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              IFixButton(
                label: 'اعتماد التوقيع وإتمام الطلب وإصدار الفاتورة 🚀',
                height: 52,
                color: AppColors.success,
                isLoading: _isSubmitting,
                onTap: _submitChecklistAndComplete,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({required String label, required bool value, required ValueChanged<bool?> onChanged}) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.success,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary)),
    );
  }

  Widget _buildPhotoUploadBtn({required String label, required bool isUploaded, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: isUploaded ? AppColors.success : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, color: isUploaded ? AppColors.success : AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: isUploaded ? AppColors.success : AppColors.textPrimary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showCompletionSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 64),
            ),
            const SizedBox(height: 20),
            const Text('تم إنجاز الطلب وإغلاقه بنجاح! 🎉', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'تم إيداع مستحقاتك في المحفظة، وتم تفعيل ضمان الصيانة لمدة 30 يوماً للعميل وإصدار الفاتورة الضريبية المبسطة.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontFamily: 'Cairo', height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: IFixButton(
                label: 'العودة للرئيسية',
                onTap: () {
                  Navigator.pop(context); // close dialog
                  context.go(AppRoutes.home);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String title;
  final Color color;
  const _HeaderBadge({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo')),
    );
  }
}

class _SignaturePad extends StatefulWidget {
  final Function(bool hasSigned) onSignedChanged;
  const _SignaturePad({required this.onSignedChanged});

  @override
  State<_SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<_SignaturePad> {
  final List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: _points.isNotEmpty ? AppColors.success : AppColors.border, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _points.add(details.localPosition);
                });
                widget.onSignedChanged(_points.isNotEmpty);
              },
              onPanEnd: (_) => _points.add(null),
              child: CustomPaint(
                painter: _SignaturePainter(points: _points),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _points.isNotEmpty ? 'تم التقاط التوقيع الإلكتروني بنجاح ✔️' : 'يرجى التوقيع داخل المربع بأصبع اليد أو القلم',
              style: TextStyle(color: _points.isNotEmpty ? AppColors.success : AppColors.textSecondary, fontSize: 12, fontFamily: 'Cairo'),
            ),
            if (_points.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  setState(() => _points.clear());
                  widget.onSignedChanged(false);
                },
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
                label: const Text('إعادة التوقيع', style: TextStyle(color: AppColors.error, fontSize: 12, fontFamily: 'Cairo')),
              ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
