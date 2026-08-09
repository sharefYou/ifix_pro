import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.engineering_rounded,
      title: 'كن شريكاً في النجاح',
      subtitle: 'انضم لشبكة واسعة من الفنيين المحترفين وزد من دخلك الشهري',
    ),
    _OnboardingPage(
      icon: Icons.notifications_active_rounded,
      title: 'طلبات مستمرة وحقيقية',
      subtitle: 'استقبل طلبات الصيانة من العملاء القريبين منك فوراً وبكل سهولة',
    ),
    _OnboardingPage(
      icon: Icons.account_balance_wallet_rounded,
      title: 'إدارة مالية شفافة',
      subtitle: 'تتبع أرباحك، مديونيتك، وطلبات التحويل بوضوح تام عبر محفظتك',
    ),
  ];

  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      setState(() => _current++);
      _ctrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFF4FB), Color(0xFFF7F9FC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('تخطي', style: TextStyle(color: AppColors.primary, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                  ),
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildPage(_pages[_current]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: AppConstants.animNormal,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _current ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _current ? AppColors.primary : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXL),
                      if (_current < _pages.length - 1)
                        IFixButton(
                          label: 'التالي',
                          onTap: _next,
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        )
                      else ...[
                        IFixButton(
                          label: 'انضم إلينا الآن',
                          onTap: () => context.go(AppRoutes.register),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('لديك حساب بالفعل؟ ', style: TextStyle(fontFamily: 'Cairo')),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: const Text('تسجيل الدخول', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppConstants.spacingSM),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(page.icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: AppConstants.spacingXL),
          Text(page.title, style: AppTextStyles.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            page.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingPage({required this.icon, required this.title, required this.subtitle});
}
