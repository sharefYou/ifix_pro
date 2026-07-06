import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ifix_button.dart';
import '../../../../core/widgets/ifix_card.dart';
import '../../../../core/widgets/ifix_text_field.dart';
import '../../logic/custom_orders_cubit.dart';
import '../../data/models/custom_order_model.dart';

class SubmitOfferScreen extends StatefulWidget {
  final CustomOrderModel? request;
  final int? bidId;
  final bool isCounter;

  const SubmitOfferScreen({
    super.key,
    this.request,
    this.bidId,
    this.isCounter = false,
  });

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  final _laborCtrl = TextEditingController();
  final _partsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _laborCtrl.addListener(_updateTotal);
    _partsCtrl.addListener(_updateTotal);
  }

  void _updateTotal() {
    final labor = double.tryParse(_laborCtrl.text.trim()) ?? 0.0;
    final parts = double.tryParse(_partsCtrl.text.trim()) ?? 0.0;
    if (labor > 0 || parts > 0) {
      _priceCtrl.text = (labor + parts).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _laborCtrl.dispose();
    _partsCtrl.dispose();
    _priceCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال سعر صحيح', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    final labor = double.tryParse(_laborCtrl.text.trim());
    final parts = double.tryParse(_partsCtrl.text.trim());
    final notes = _messageCtrl.text.trim();

    if (widget.isCounter && widget.bidId != null) {
      context.read<CustomOrdersCubit>().submitCounterOffer(
        bidId: widget.bidId!,
        counterPrice: price,
        counterNotes: notes,
      );
    } else if (widget.request != null) {
      context.read<CustomOrdersCubit>().submitBid(
        customRequestId: widget.request!.id,
        price: price,
        laborCost: labor,
        partsCost: parts,
        notes: notes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCounter ? 'تقديم عرض مقابل' : 'تقديم عرض سعر'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: BlocConsumer<CustomOrdersCubit, CustomOrdersState>(
        listener: (context, state) {
          if (state is CustomOrderActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo'))),
            );
            context.pop();
          } else if (state is CustomOrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CustomOrderActionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.request != null) ...[
                  IFixCard(
                    color: AppColors.surfaceVariant,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('وصف طلب العميل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo')),
                            Text(widget.request!.visitDate, style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.request!.description, style: AppTextStyles.bodyMedium),
                        if (widget.request!.city != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(widget.request!.city!, style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SectionHeader(title: 'تسعير تفصيلي (اختياري)'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: IFixTextField(
                        hint: 'أجور اليد',
                        label: 'أجور الشغل (ريال)',
                        controller: _laborCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IFixTextField(
                        hint: 'تكلفة القطع',
                        label: 'قطع الغيار (ريال)',
                        controller: _partsCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const SectionHeader(title: 'عرضك المالي الإجمالي'),
                const SizedBox(height: 12),
                IFixTextField(
                  hint: 'أدخل السعر الإجمالي',
                  label: 'السعر الإجمالي (ريال)',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payments_rounded, size: 20, color: AppColors.gold),
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
                  hint: 'اكتب تفاصيل عن عرضك، الضمان المتوفر، أو موعد وصولك...',
                  controller: _messageCtrl,
                  maxLines: 4,
                ),

                const SizedBox(height: 32),

                IFixButton(
                  label: widget.isCounter ? 'إرسال العرض المقابل' : 'إرسال العرض',
                  onTap: _onSubmit,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'Cairo',
      ),
    );
  }
}
