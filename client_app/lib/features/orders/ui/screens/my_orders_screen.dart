import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/order_model.dart';
import '../../manager/orders_cubit.dart';
import '../../manager/orders_states.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    context.read<OrdersCubit>().fetchMyOrders();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
          title: const Text('طلبات الصيانة والمواعيد', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            controller: tabController,
            labelColor: tertiaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: tertiaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'الحالية النشطة'),
              Tab(text: 'المكتملة'),
              Tab(text: 'الملغاة'),
            ],
          ),
        ),
        body: BlocBuilder<OrdersCubit, OrdersStates>(
          builder: (context, state) {
            final orders = context.read<OrdersCubit>().myOrders;
            if (state is OrdersLoadingState) {
              return const Center(child: CircularProgressIndicator(color: tertiaryColor));
            } else if (state is OrdersErrorState && orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error, style: const TextStyle(color: textColor)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor),
                      onPressed: () => context.read<OrdersCubit>().fetchMyOrders(),
                      child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            final active = orders.where((o) => o.status != 'completed' && o.status != 'canceled').toList();
            final completed = orders.where((o) => o.status == 'completed').toList();
            final cancelled = orders.where((o) => o.status == 'canceled').toList();

            return TabBarView(
              controller: tabController,
              children: [
                _buildOrderList(active, emptyMsg: 'لا توجد طلبات صيانة نشطة حالياً'),
                _buildOrderList(completed, emptyMsg: 'لا توجد طلبات صيانة مكتملة'),
                _buildOrderList(cancelled, emptyMsg: 'لا توجد طلبات ملغاة'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> list, {required String emptyMsg}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 70, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(emptyMsg, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: tertiaryColor,
      onRefresh: () => context.read<OrdersCubit>().fetchMyOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (context, i) => const SizedBox(height: 12),
        itemBuilder: (context, idx) => _buildOrderTile(list[idx]),
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    final statusColor = _statusColor(order.status);
    return InkWell(
      onTap: () => context.push(OrderDetailsScreen(order: order)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [BoxShadow(color: textColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(order.statusArabic, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.home_repair_service, color: tertiaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(order.serviceName ?? 'صيانة منزلية عامة', style: const TextStyle(fontWeight: FontWeight.bold, color: textColor))),
              ],
            ),
            const SizedBox(height: 8),
            if (order.visitDate != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(order.visitDate!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي: ${order.totalAmount} ريال', style: const TextStyle(fontWeight: FontWeight.bold, color: tertiaryColor)),
                const Row(
                  children: [
                    Text('التفاصيل', style: TextStyle(color: tertiaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: tertiaryColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'in_progress':
      case 'on_the_way':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
