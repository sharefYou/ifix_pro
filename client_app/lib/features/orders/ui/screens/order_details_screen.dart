import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/order_model.dart';
import '../../manager/orders_cubit.dart';
import '../../manager/orders_states.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

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
                  context.pop();
                } else if (state is OrderActionErrorState) {
                  context.showOverlaySnackBar(message: state.error, type: Error());
                }
              },
              builder: (context, state) {
                final isLoading = state is OrderActionLoadingState;
                if (!isActive && order.status != 'completed') return const SizedBox();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: isLoading ? null : () => context.read<OrdersCubit>().completeOrder(order.id),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('تأكيد إنجاز الصيانة (Complete)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: isLoading ? null : () => context.read<OrdersCubit>().cancelOrder(order.id),
                          child: const Text('إلغاء الطلب (Cancel)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else if (order.status == 'completed') ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          icon: const Icon(Icons.star, color: Colors.amberAccent),
                          label: const Text('تقييم الخدمة والفني (Review)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: () => _showReviewModal(context, order.id),
                        ),
                      ),
                    ],
                  ],
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
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
                    child: const Text('إرسال التقييم', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
}
