import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ifix_tech/core/constants/app_colors.dart';
import 'package:ifix_tech/core/constants/app_constants.dart';
import 'package:ifix_tech/core/constants/app_text_styles.dart';
import 'package:ifix_tech/core/routing/app_router.dart';
import 'package:ifix_tech/core/widgets/ifix_button.dart';
import 'package:ifix_tech/core/widgets/ifix_card.dart';
import 'package:ifix_tech/features/orders/logic/order_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = true;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => setState(() => _isOnline = !_isOnline),
              backgroundColor: _isOnline ? AppColors.success : AppColors.error,
              child: Icon(
                _isOnline
                    ? Icons.power_rounded
                    : Icons.power_settings_new_rounded,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        children: [
          const Text('iFix Pro'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOnline ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isOnline ? 'متصل الآن' : 'أنت غير متصل',
                style: AppTextStyles.caption.copyWith(
                  color: _isOnline ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Badge(
            label: Text('3'),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _HomeContent(isOnline: _isOnline),
        const Center(child: Text('الطلبات الخاصة')),
        const Center(child: Text('المحفظة')),
        const Center(child: Text('الملف الشخصي')),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        if (i == 2) {
          context.push(AppRoutes.wallet);
        } else if (i == 3) {
          context.push(AppRoutes.profile);
        } else if (i == 1) {
          context.push(AppRoutes.customOrders);
        } else {
          setState(() => _currentIndex = i);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_rounded),
          label: 'طلبات خاصة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_rounded),
          label: 'المحفظة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'حسابي',
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  final bool isOnline;

  const _HomeContent({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<OrderCubit>().getAvailableOrders(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _QuickStatCard(
                    'أرباح اليوم',
                    '245',
                    'ل.س',
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStatCard('التقييم', '4.9', '⭐', AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isOnline)
              _buildOfflineAlert()
            else ...[
              const SectionHeader(title: 'طلبات جديدة (مباشرة)'),
              const SizedBox(height: 12),
              BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OrderError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is OrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text('لا يوجد طلبات متاحة حالياً'),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final order = state.orders[i];
                        return _NewOrderCard(
                          serviceName:
                              order['service']?['name_ar'] ?? 'خدمة صيانة',
                          customerName: order['customer']?['name'] ?? 'عميل',
                          distance: '1.5 كم',
                          price:
                              double.tryParse(
                                order['total_price'].toString(),
                              )?.toInt() ??
                              0,
                          onAccept: () => context.push(
                            AppRoutes.orderDetails,
                            extra: {'orderId': order['id'], 'orderData': order},
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineAlert() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.power_settings_new_rounded,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'أنت غير متصل حالياً',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لن تستقبل أي طلبات جديدة حتى تقوم بتغيير حالتك إلى "متصل"',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;

  const _QuickStatCard(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return IFixCard(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.displayMedium.copyWith(color: color),
              ),
              const SizedBox(width: 4),
              Text(unit, style: AppTextStyles.bodySmall.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewOrderCard extends StatelessWidget {
  final String serviceName, customerName, distance;
  final int price;
  final VoidCallback onAccept;

  const _NewOrderCard({
    required this.serviceName,
    required this.customerName,
    required this.distance,
    required this.price,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return IFixCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: const Icon(
                  Icons.location_searching_rounded,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceName, style: AppTextStyles.headlineSmall),
                    Text(
                      'العميل: $customerName',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$price ل.س',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    distance,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IFixButton(
                  label: 'عرض التفاصيل',
                  height: 44,
                  onTap: onAccept,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: IFixButton(
                  label: 'تجاهل',
                  height: 44,
                  isOutlined: true,
                  color: AppColors.textSecondary,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
