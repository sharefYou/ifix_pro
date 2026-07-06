import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/order_model.dart';
import '../../manager/orders_cubit.dart';
import '../../manager/orders_states.dart';
import 'chat_screen.dart';
import 'live_tracking_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color tertiaryColor = Color(0xFF2979FF);
  static const Color borderColor = Color(0xFF30363D);
  static const Color textColor = Color(0xFFF0F6FC);

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isActive = order.status != 'completed' && order.status != 'canceled';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: const BackButton(color: textColor),
          title: Text('تفاصيل الطلب #${order.id}', style: const TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocConsumer<OrdersCubit, OrdersStates>(
              listener: (context, state) {
                if (state is OrderActionSuccessState) {
                  context.showOverlaySnackBar(message: state.message, type: Success());
                } else if (state is OrderActionErrorState) {
                  context.showOverlaySnackBar(message: state.error, type: Error());
                }
              },
              builder: (context, state) {
                final isLoading = state is OrderActionLoadingState;
                if (!isActive && order.status != 'completed') return const SizedBox();

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 12)),
                                icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                                label: const Text('المحادثة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(orderId: order.id, recipientName: order.technicianName ?? 'الفني'))),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 12)),
                                icon: const Icon(Icons.location_on, color: Colors.white, size: 20),
                                label: const Text('تتبع GPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveTrackingScreen(orderId: order.id, technicianName: order.technicianName ?? 'الفني', technicianPhone: '0500000000'))),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            icon: const Icon(Icons.warning_rounded, color: Colors.redAccent),
                            label: const Text('زر الطوارئ الفوري (SOS Emergency)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                            onPressed: () => _triggerSosAlert(context, order.id),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            onPressed: isLoading ? null : () => context.read<OrdersCubit>().completeOrder(order.id),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('تأكيد إنجاز الصيانة (Complete)', style: TextStyle(color: Color(0xFF161B22), fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            onPressed: isLoading ? null : () => context.read<OrdersCubit>().cancelOrder(order.id),
                            child: const Text('إلغاء الطلب (Cancel)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ] else if (order.status == 'completed') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF059669))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.verified, color: Color(0xFF10B981), size: 24),
                                  SizedBox(width: 8),
                                  Text('ضمان موثق فعال (30 يوم)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              TextButton(
                                onPressed: () => _claimWarranty(context, order.id),
                                style: TextButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                                child: const Text('مطالبة بالضمان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 12)),
                                icon: const Icon(Icons.star, color: Colors.amberAccent),
                                label: const Text('تقييم', style: TextStyle(color: Color(0xFF161B22), fontSize: 15, fontWeight: FontWeight.bold)),
                                onPressed: () => _showReviewModal(context, order.id),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF374151), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 12)),
                                icon: const Icon(Icons.receipt_long, color: Colors.white),
                                label: const Text('الفاتورة', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                onPressed: () => _showInvoiceModal(context, order),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('حالة الطلب:', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        Text(order.statusArabic, style: const TextStyle(fontWeight: FontWeight.bold, color: tertiaryColor, fontSize: 16)),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow('الخدمة المطلوبة', order.serviceName ?? 'صيانة عامة'),
                    const SizedBox(height: 12),
                    _buildDetailRow('نوع الزيارة', order.visitType == 'home' ? 'منزلية' : 'في المركز'),
                    if (order.visitDate != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('الموعد المحدّد', order.visitDate!),
                    ],
                    const SizedBox(height: 12),
                    _buildDetailRow('طريقة الدفع', order.paymentMethod == 'wallet' ? 'المحفظة الإلكترونية' : 'نقداً عند الإنجاز'),
                    const SizedBox(height: 12),
                    _buildDetailRow('المبلغ الإجمالي', '${order.totalAmount} ريال'),
                  ],
                ),
              ),
              if (order.technicianName != null) ...[
                const SizedBox(height: 24),
                const Text('بيانات الفني المختص', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: tertiaryColor, child: Icon(Icons.engineering, color: Colors.white)),
                      const SizedBox(width: 16),
                      Expanded(child: Text(order.technicianName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
                      IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () {}),
                    ],
                  ),
                ),
              ],
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('الملاحظات المسجلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                  child: Text(order.notes!, style: TextStyle(color: textColor.withValues(alpha: 0.8), height: 1.5)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
      ],
    );
  }

  void _showReviewModal(BuildContext context, int orderId) {
    int tRate = 5;
    int qRate = 5;
    int cRate = 5;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تقييم أداء الفني والخدمة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 20),
                _buildStarSelector('الالتزام بالوقت', tRate, (r) => setModalState(() => tRate = r)),
                const SizedBox(height: 12),
                _buildStarSelector('جودة الصيانة', qRate, (r) => setModalState(() => qRate = r)),
                const SizedBox(height: 12),
                _buildStarSelector('نظافة المكان بعد العمل', cRate, (r) => setModalState(() => cRate = r)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      context.read<OrdersCubit>().submitReview(
                            orderId: orderId,
                            timeRating: tRate,
                            qualityRating: qRate,
                            cleanlinessRating: cRate,
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('إرسال التقييم', style: TextStyle(color: Color(0xFF161B22), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarSelector(String title, int current, ValueChanged<int> onSelect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        Row(
          children: List.generate(5, (i) {
            final starNum = i + 1;
            return InkWell(
              onTap: () => onSelect(starNum),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(starNum <= current ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showInvoiceModal(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('فاتورة ضريبية مبسطة (Simple Invoice)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.receipt_long, color: Color(0xFF2979FF)),
                ],
              ),
              const Divider(height: 32, color: Color(0xFF30363D)),
              _buildDetailRow('رقم الطلب (Order ID)', '#${order.id}'),
              const SizedBox(height: 12),
              _buildDetailRow('الخدمة (Service)', order.serviceName ?? 'صيانة عامة'),
              const SizedBox(height: 12),
              _buildDetailRow('أجور اليد العاملة (Labor)', '${order.totalAmount} ريال'),
              const SizedBox(height: 12),
              _buildDetailRow('قطع الغيار (Parts)', '0.00 ريال'),
              const SizedBox(height: 12),
              _buildDetailRow('خصم المنصة (Discount)', '0.00 ريال'),
              const Divider(height: 32, color: Color(0xFF30363D)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي النهائي (Total)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${order.totalAmount} ريال', style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2979FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق الفاتورة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _triggerSosAlert(BuildContext context, int orderId) async {
    try {
      final res = await DioHelper.postData(
        endPoint: '/api/v1/general/sos/alert',
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
            backgroundColor: const Color(0xFF161B22),
            title: const Row(children: [Icon(Icons.warning, color: Colors.redAccent), SizedBox(width: 8), Text('تم إرسال بلاغ الطوارئ!', style: TextStyle(color: Colors.white))]),
            content: const Text('تم إبلاغ الإدارة وفريق التدخل السريع بموقعك الحالي وحالة الطوارئ.', style: TextStyle(color: Colors.white70)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً', style: TextStyle(color: Colors.blueAccent)))],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء إرسال بلاغ الطوارئ')));
      }
    }
  }

  Future<void> _claimWarranty(BuildContext context, int orderId) async {
    try {
      final res = await DioHelper.postData(endPoint: '/api/v1/customer/orders/$orderId/claim-warranty');
      if (res.statusCode == 201 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع طلب المطالبة بالضمان بنجاح')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الطلب غير مؤهل للمطالبة بالضمان أو انتهت صلاحيته')));
      }
    }
  }
}




