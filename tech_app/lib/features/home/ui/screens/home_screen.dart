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
import 'package:ifix_tech/core/utils/navigation_helper.dart';

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

class _HomeContent extends StatefulWidget {
  final bool isOnline;

  const _HomeContent({required this.isOnline});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _showMyOrders = false;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getAvailableOrders();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _showMyOrders ? context.read<OrderCubit>().getMyOrders() : context.read<OrderCubit>().getAvailableOrders(),
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
                    'ريال',
                    AppColors.accent,
                    onTap: () => context.push(AppRoutes.analytics),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStatCard(
                    'التقييم',
                    '4.9',
                    '⭐',
                    AppColors.gold,
                    onTap: () => context.push(AppRoutes.analytics),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.push(AppRoutes.analytics),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                      ),
                      child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لوحة التحليلات المالية والأداء 📈',
                        style: AppTextStyles.headlineSmall.copyWith(fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!widget.isOnline)
              _buildOfflineAlert()
            else ...[
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_showMyOrders) {
                          setState(() => _showMyOrders = false);
                          context.read<OrderCubit>().getAvailableOrders();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_showMyOrders ? AppColors.accent : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'طلبات جديدة (مباشرة) 🟢',
                          style: TextStyle(
                            color: !_showMyOrders ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_showMyOrders) {
                          setState(() => _showMyOrders = true);
                          context.read<OrderCubit>().getMyOrders();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _showMyOrders ? AppColors.accent : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'طلباتي النشطة (المسار) 🚚',
                          style: TextStyle(
                            color: _showMyOrders ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showMyOrders ? 'مسار العمل والزيارات اليومية' : 'الطلبات المتاحة في منطقتك',
                    style: AppTextStyles.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => context.read<OrderCubit>().sortOrdersByProximity(),
                    icon: const Icon(Icons.near_me_rounded, size: 16, color: AppColors.accent),
                    label: const Text('ترتيب حسب الأقرب 📍', style: TextStyle(color: AppColors.accent, fontSize: 13, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  if (state is OrderError) {
                    return Center(child: Padding(padding: EdgeInsets.all(20), child: Text(state.message, style: const TextStyle(fontFamily: 'Cairo'))));
                  }
                  List<dynamic> orders = [];
                  if (!_showMyOrders && state is OrdersLoaded) {
                    orders = state.orders;
                  } else if (_showMyOrders && state is MyOrdersLoaded) {
                    orders = state.orders;
                  } else if (state is OrdersLoaded) {
                    orders = state.orders;
                  } else if (state is MyOrdersLoaded) {
                    orders = state.orders;
                  }

                  if (orders.isEmpty && (state is OrdersLoaded || state is MyOrdersLoaded)) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(_showMyOrders ? 'لا يوجد طلبات نشطة حالياً' : 'لا يوجد طلبات متاحة حالياً', style: const TextStyle(fontFamily: 'Cairo')),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final order = orders[i];
                      return _NewOrderCard(
                        serviceName: order['service']?['name_ar'] ?? 'خدمة صيانة',
                        customerName: order['customer']?['name'] ?? 'عميل',
                        distance: NavigationHelper.calculateDistanceKm(order),
                        price: double.tryParse(order['total_price']?.toString() ?? '0')?.toInt() ?? 0,
                        isActiveOrder: _showMyOrders,
                        onAccept: () => context.push(
                          AppRoutes.orderDetails,
                          extra: {'orderId': order['id'], 'orderData': order},
                        ),
                        onSecondaryAction: _showMyOrders
                            ? () => NavigationHelper.launchNavigation(
                                  context,
                                  double.tryParse(order['user']?['lat']?.toString() ?? ''),
                                  double.tryParse(order['user']?['lng']?.toString() ?? ''),
                                  customerName: order['customer']?['name'],
                                )
                            : () {},
                      );
                    },
                  );
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
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.power_settings_new_rounded,
              color: AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'أنت غير متصل حالياً',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لن تستقبل أي طلبات جديدة حتى تقوم بتغيير حالتك إلى "متصل"',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final VoidCallback? onTap;

  const _QuickStatCard(this.label, this.value, this.unit, this.color, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IFixCard(
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
      ),
    );
  }
}

class _NewOrderCard extends StatelessWidget {
  final String serviceName, customerName, distance;
  final int price;
  final bool isActiveOrder;
  final VoidCallback onAccept;
  final VoidCallback? onSecondaryAction;

  const _NewOrderCard({
    required this.serviceName,
    required this.customerName,
    required this.distance,
    required this.price,
    this.isActiveOrder = false,
    required this.onAccept,
    this.onSecondaryAction,
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
                    '$price ريال',
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
                  label: isActiveOrder ? 'بدء التوجيه 🧭' : 'تجاهل',
                  height: 44,
                  isOutlined: !isActiveOrder,
                  color: isActiveOrder ? AppColors.success : AppColors.textSecondary,
                  onTap: onSecondaryAction ?? () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
