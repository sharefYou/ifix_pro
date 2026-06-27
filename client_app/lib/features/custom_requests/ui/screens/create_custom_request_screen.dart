import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../manager/custom_requests_cubit.dart';
import '../../manager/custom_requests_states.dart';

class CreateCustomRequestScreen extends StatefulWidget {
  const CreateCustomRequestScreen({super.key});

  @override
  State<CreateCustomRequestScreen> createState() => _CreateCustomRequestScreenState();
}

class _CreateCustomRequestScreenState extends State<CreateCustomRequestScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  final descController = TextEditingController();
  DateTime? selectedDate;
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    descController.dispose();
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
          title: const Text('طلب صيانة خاص (مناقصة)', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocConsumer<CustomRequestsCubit, CustomRequestsStates>(
          listener: (context, state) {
            if (state is CreateCustomRequestSuccessState) {
              context.showOverlaySnackBar(message: 'تم طرح طلبك المخصص بنجاح، ستتلقى عروض أسعار من الفنيين قريباً', type: Success());
              context.pop();
            } else if (state is CreateCustomRequestErrorState) {
              context.showOverlaySnackBar(message: state.error, type: Error());
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateCustomRequestLoadingState;
            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: tertiaryColor, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'هل لديك عطل غير مدرج في القائمة؟ صف مشكلتك هنا وسيقوم الفنيون بتقديم عروض أسعار تنافسية لك.',
                            style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('وصف العطل أو المطلوب بدقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descController,
                    maxLines: 5,
                    validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء كتابة تفاصيل الطلب' : null,
                    decoration: InputDecoration(
                      hintText: 'مثال: أريد تركيب 4 مكيفات سبليت مع تمديد نحاس في الدور الثاني...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('التاريخ المتوقع للتنفيذ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: tertiaryColor),
                          const SizedBox(width: 12),
                          Text(selectedDate == null ? 'اختر تاريخ الزيارة المقترح' : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}', style: const TextStyle(color: textColor)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                if (selectedDate == null) {
                                  context.showOverlaySnackBar(message: 'الرجاء اختيار تاريخ التنفيذ المقترح', type: Error());
                                  return;
                                }
                                final dtStr = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} 12:00:00';
                                context.read<CustomRequestsCubit>().createCustomRequest(
                                      description: descController.text.trim(),
                                      visitDate: dtStr,
                                    );
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('نشر الطلب لتلقي العروض', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
