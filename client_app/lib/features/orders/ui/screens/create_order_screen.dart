import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../../services/data/models/service_model.dart';
import '../../manager/orders_cubit.dart';
import '../../manager/orders_states.dart';

class CreateOrderScreen extends StatefulWidget {
  final ServiceModel service;
  const CreateOrderScreen({super.key, required this.service});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  String visitType = 'home';
  String paymentMethod = 'wallet';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (d != null) {
      setState(() => selectedDate = d);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (t != null) {
      setState(() => selectedTime = t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: const BackButton(color: textColor),
          title: const Text('تأكيد حجز الصيانة', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocConsumer<OrdersCubit, OrdersStates>(
          listener: (context, state) {
            if (state is CreateOrderSuccessState) {
              context.showOverlaySnackBar(message: 'تم إنشاء طلب الصيانة بنجاح، جاري البحث عن فني', type: Success());
              context.popUntil();
            } else if (state is CreateOrderErrorState) {
              context.showOverlaySnackBar(message: state.error, type: Error());
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateOrderLoadingState;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.build_circle, color: tertiaryColor, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.service.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 4),
                            Text('التكلفة المقدرة: ${widget.service.price} ريال', style: const TextStyle(color: tertiaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('نوع الزيارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildChoiceRadio('زيارة منزلية (Home)', 'home', visitType, (val) => setState(() => visitType = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildChoiceRadio('في المركز (Workshop)', 'workshop', visitType, (val) => setState(() => visitType = val))),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('موعد الزيارة المناسب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: tertiaryColor),
                              const SizedBox(width: 12),
                              Text(selectedDate == null ? 'اختر التاريخ' : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}', style: const TextStyle(color: textColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: tertiaryColor),
                              const SizedBox(width: 12),
                              Text(selectedTime == null ? 'اختر الوقت' : selectedTime!.format(context), style: const TextStyle(color: textColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('طريقة الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildChoiceRadio('المحفظة الإلكترونية', 'wallet', paymentMethod, (val) => setState(() => paymentMethod = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildChoiceRadio('الدفع عند الإنجاز (نقداً)', 'cash', paymentMethod, (val) => setState(() => paymentMethod = val))),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('ملاحظات إضافية للفني', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'وصف المشكلة بدقة أو تعليمات الدخول للمنزل...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: borderColor)),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tertiaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: isLoading
                          ? null
                          : () {
                              if (selectedDate == null || selectedTime == null) {
                                context.showOverlaySnackBar(message: 'الرجاء اختيار تاريخ ووقت الزيارة', type: Error());
                                return;
                              }
                              final dtString = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00';
                              context.read<OrdersCubit>().createOrder(
                                    serviceId: widget.service.id,
                                    visitType: visitType,
                                    visitDate: dtString,
                                    notes: notesController.text.trim(),
                                    paymentMethod: paymentMethod,
                                    totalAmount: widget.service.price,
                                  );
                            },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تأكيد وإرسال الطلب', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChoiceRadio(String title, String val, String groupVal, ValueChanged<String> onChanged) {
    final isSel = val == groupVal;
    return InkWell(
      onTap: () => onChanged(val),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSel ? tertiaryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? tertiaryColor : borderColor, width: isSel ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSel ? tertiaryColor : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: textColor, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}
