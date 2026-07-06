import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_card.dart';
import '../../logic/custom_orders_cubit.dart';
import '../../data/models/custom_order_model.dart';
import '../../data/models/bid_model.dart';

class CustomOrdersListScreen extends StatefulWidget {
  const CustomOrdersListScreen({super.key});

  @override
  State<CustomOrdersListScreen> createState() => _CustomOrdersListScreenState();
}

class _CustomOrdersListScreenState extends State<CustomOrdersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    context.read<CustomOrdersCubit>().loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات الخاصة'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'الطلبات المتاحة'),
            Tab(text: 'عروضي والمفاوضات'),
          ],
        ),
      ),
      body: BlocConsumer<CustomOrdersCubit, CustomOrdersState>(
        listener: (context, state) {
          if (state is CustomOrderActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo'))),
            );
          } else if (state is CustomOrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomOrdersLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          List<CustomOrderModel> available = [];
          List<BidModel> myBids = [];

          if (state is CustomOrdersLoaded) {
            available = state.availableRequests;
            myBids = state.myBids;
          }

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildAvailableTab(available),
              _buildMyBidsTab(myBids),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvailableTab(List<CustomOrderModel> available) {
    if (available.isEmpty) {
      return const Center(
        child: Text('لا توجد طلبات خاصة متاحة حالياً في مدينتك', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<CustomOrdersCubit>().loadData(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
        itemCount: available.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = available[i];
          return _CustomOrderListItem(
            id: item.id,
            description: item.description,
            city: item.city ?? 'الرياض',
            date: item.visitDate,
            onTap: () => context.push(AppRoutes.submitOffer, extra: {'request': item}),
          );
        },
      ),
    );
  }

  Widget _buildMyBidsTab(List<BidModel> myBids) {
    if (myBids.isEmpty) {
      return const Center(
        child: Text('لم تقم بتقديم أي عروض أسعار حتى الآن', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<CustomOrdersCubit>().loadData(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
        itemCount: myBids.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final bid = myBids[i];
          final isCustomerCounter = bid.counterBy == 'customer' && bid.counterStatus == 'pending';

          return IFixCard(
            color: isCustomerCounter ? AppColors.gold.withValues(alpha: 0.1) : AppColors.surface,
            showBorder: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('طلب رقم #${bid.customRequestId}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold)),
                    _buildStatusBadge(bid),
                  ],
                ),
                const SizedBox(height: 8),
                if (bid.customRequest != null)
                  Text(bid.customRequest!.description, style: AppTextStyles.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('عرضك المالي:', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text('${bid.price} ريال', style: AppTextStyles.labelMedium.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (bid.laborCost != null && bid.partsCost != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('تفصيل السعر:', style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                      Text('أجور شغل: ${bid.laborCost} + قطع غيار: ${bid.partsCost}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                ],
                if (isCustomerCounter) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_offer_rounded, color: AppColors.gold, size: 16),
                            SizedBox(width: 6),
                            Text('عرض مقابل من العميل!', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo')),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('السعر المقترح: ${bid.counterPrice} ريال', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        if (bid.counterNotes != null && bid.counterNotes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('ملاحظة: "${bid.counterNotes}"', style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic)),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                                onPressed: () => context.read<CustomOrdersCubit>().acceptCounterOffer(bid.id),
                                child: const Text('قبول العرض', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.accent)),
                                onPressed: () {
                                  if (bid.customRequest != null) {
                                    context.push(AppRoutes.submitOffer, extra: {'request': bid.customRequest, 'bidId': bid.id, 'isCounter': true});
                                  }
                                },
                                child: const Text('تفاوض مجدداً', style: TextStyle(color: AppColors.accent, fontFamily: 'Cairo')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(BidModel bid) {
    String label = 'قيد المراجعة';
    Color color = Colors.orange;

    if (bid.status == 'accepted') {
      label = 'تم القبول';
      color = Colors.green;
    } else if (bid.status == 'rejected') {
      label = 'تم الرفض';
      color = Colors.red;
    } else if (bid.counterBy == 'customer' && bid.counterStatus == 'pending') {
      label = 'عرض مقابل من العميل';
      color = AppColors.gold;
    } else if (bid.counterBy == 'technician' && bid.counterStatus == 'pending') {
      label = 'بانتظار رد العميل';
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }
}

class _CustomOrderListItem extends StatelessWidget {
  final int id;
  final String description;
  final String city;
  final String date;
  final VoidCallback onTap;

  const _CustomOrderListItem({
    required this.id,
    required this.description,
    required this.city,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IFixCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('طلب #$id', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold, width: 0.5),
                ),
                child: const Text('جديد', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.bodyLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(city, style: AppTextStyles.caption),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(date, style: AppTextStyles.caption),
              const Spacer(),
              Text(
                'قدم عرضك',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}
