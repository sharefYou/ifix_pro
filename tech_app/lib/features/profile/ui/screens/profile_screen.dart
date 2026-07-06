import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_button.dart';
import '../../../../core/widgets/ifix_card.dart';
import '../../../../core/widgets/ifix_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isOnline = true;
  final _nameCtrl = TextEditingController(text: 'أحمد محمد العلي');
  final _phoneCtrl = TextEditingController(text: '0933123456');
  final _specialtyCtrl = TextEditingController(text: 'مكيفات');
  final _ibanCtrl = TextEditingController(text: 'SY12 0011 2233 4455 6677 8899');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _specialtyCtrl.dispose();
    _ibanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Availability Toggle
            _buildAvailabilityCard(),
            const SizedBox(height: 24),

            // Form Fields
            const SectionHeader(title: 'البيانات الشخصية'),
            const SizedBox(height: 12),
            IFixTextField(
              hint: 'الاسم الكامل',
              label: 'الاسم',
              controller: _nameCtrl,
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            ),
            const SizedBox(height: 16),
            IFixTextField(
              hint: 'رقم الجوال',
              label: 'الجوال',
              controller: _phoneCtrl,
              readOnly: true,
              prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
            ),
            const SizedBox(height: 16),
            IFixTextField(
              hint: 'التخصص',
              label: 'التخصص',
              controller: _specialtyCtrl,
              readOnly: true,
              prefixIcon: const Icon(Icons.engineering_rounded, size: 20),
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: 'بيانات التحويل البنكي'),
            const SizedBox(height: 12),
            IFixTextField(
              hint: 'رقم الآيبان',
              label: 'IBAN',
              controller: _ibanCtrl,
              prefixIcon: const Icon(Icons.account_balance_rounded, size: 20),
            ),

            const SizedBox(height: 32),

            IFixButton(
              label: 'حفظ التغييرات',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Menu Items
            _MenuItem(Icons.analytics_outlined, 'التحليلات المالية والأداء 📈', AppColors.gold, () => context.push(AppRoutes.analytics)),
            _MenuItem(Icons.description_outlined, 'الشروط والأحكام', AppColors.textSecondary, () {}),
            _MenuItem(Icons.headset_mic_outlined, 'تواصل مع الدعم الفني', AppColors.textSecondary, () {}),
            _MenuItem(Icons.logout_rounded, 'تسجيل الخروج', AppColors.error, () => context.go(AppRoutes.login)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 48),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('أحمد محمد العلي', style: AppTextStyles.headlineLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
            const SizedBox(width: 4),
            Text('4.9', style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold)),
            const SizedBox(width: 4),
            Text('(127 تقييم)', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    return IFixCard(
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.power_rounded : Icons.power_off_rounded,
            color: _isOnline ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حالة الاستعداد', style: AppTextStyles.headlineSmall),
                Text(
                  _isOnline ? 'أنت متصل وتستقبل الطلبات الآن' : 'أنت غير متصل، لن تصلك أي طلبات',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isOnline,
            onChanged: (v) => setState(() => _isOnline = v),
            activeTrackColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(label, style: AppTextStyles.bodyLarge),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}
