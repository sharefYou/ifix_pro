import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../../custom_requests/ui/screens/my_custom_requests_screen.dart';
import '../../../orders/ui/screens/my_orders_screen.dart';
import '../../../profile/ui/screens/profile_screen.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/manager/services_cubit.dart';
import '../../../services/manager/services_states.dart';
import '../../../services/ui/screens/category_services_screen.dart';
import '../../../services/ui/screens/search_screen.dart';
import '../../../services/ui/screens/services_screen.dart';
import '../../../wallet/ui/screens/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color tertiaryColor = Color(0xFF1565C0);
  static const Color borderColor = Color(0xFFDDE4EF);
  static const Color textColor = Color(0xFF1A2332);

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeDashboard(context),
          const MyOrdersScreen(),
          const WalletScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: const Border(top: BorderSide(color: borderColor)),
          boxShadow: [BoxShadow(color: textColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF161B22),
          selectedItemColor: tertiaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'طلباتي'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: tertiaryColor,
        onRefresh: () async {
          context.read<ServicesCubit>().fetchServices();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أهلاً بك في iFix Pro 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    SizedBox(height: 4),
                    Text('ما هي الخدمة التي تحتاجها اليوم؟', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _currentIndex = 3),
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: tertiaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => context.push(const SearchScreen()),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: tertiaryColor),
                    SizedBox(width: 12),
                    Text('ابحث عن كهرباء، سباكة، تكييف...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => context.push(const MyCustomRequestsScreen()),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [tertiaryColor, Color(0xFFA54848)], begin: Alignment.centerRight, end: Alignment.centerLeft),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: tertiaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('لديك عطل مخصص ومستعجل؟', style: TextStyle(color: Color(0xFF161B22), fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('اطرح مناقصة واحصل على عروض أسعار من فنيين معتمدين بالقرب منك في دقائق.', style: TextStyle(color: Color(0xFF161B22), fontSize: 13, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.handyman, color: Color(0xFF161B22), size: 36),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('أقسام الصيانة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                TextButton(
                  onPressed: () => context.push(const ServicesScreen()),
                  child: const Text('عرض الكل', style: TextStyle(color: tertiaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<ServicesCubit, ServicesStates>(
              builder: (context, state) {
                if (state is ServicesLoadingState) {
                  return const Center(
                    child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: tertiaryColor)),
                  );
                } else if (state is ServicesErrorState) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(state.error, style: const TextStyle(color: Colors.red)),
                  );
                } else if (state is ServicesLoadedState) {
                  final categories = state.categories;
                  if (categories.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text('لا توجد أقسام متاحة حالياً'),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: categories.length > 6 ? 6 : categories.length,
                    itemBuilder: (context, i) {
                      final c = categories[i];
                      return _buildCategoryCard(context, c);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ServiceCategoryModel category) {
    return InkWell(
      onTap: () => context.push(CategoryServicesScreen(category: category)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [BoxShadow(color: textColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: category.icon != null
                  ? Image.network(category.icon!, width: 28, height: 28, errorBuilder: (_, _, _) => const Icon(Icons.category_outlined, color: tertiaryColor, size: 28))
                  : const Icon(Icons.category_outlined, color: tertiaryColor, size: 28),
            ),
            const Spacer(),
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${category.services.length} خدمة صيانة',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}



