import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_button.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String _selected = 'ar';
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, _selected);
    if (mounted) {
      await context.setLocale(Locale(_selected));
      if (!mounted) return;
      context.go(AppRoutes.welcome);
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
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingHorizontal,
                  vertical: AppConstants.spacingXXL,
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    _buildLogo(),
                    const SizedBox(height: AppConstants.spacingXXL),
                    Text(
                      'اختر لغة التطبيق\nSelect App Language',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),
                    _LanguageOption(
                      code: 'ar',
                      label: 'العربية',
                      sublabel: 'Arabic',
                      flag: '🇸🇦',
                      selected: _selected == 'ar',
                      onTap: () => setState(() => _selected = 'ar'),
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                    _LanguageOption(
                      code: 'en',
                      label: 'English',
                      sublabel: 'الإنجليزية',
                      flag: '🇺🇸',
                      selected: _selected == 'en',
                      onTap: () => setState(() => _selected = 'en'),
                    ),
                    const Spacer(),
                    IFixButton(
                      label: _selected == 'ar' ? 'متابعة' : 'Continue',
                      onTap: _onContinue,
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'iF',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'iFix-Tech',
          style: AppTextStyles.displayLarge.copyWith(
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppColors.accent, AppColors.gold],
              ).createShader(const Rect.fromLTWH(0, 0, 150, 50)),
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String label;
  final String sublabel;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.sublabel,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animNormal,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: selected ? null : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
          width: selected ? 1.5 : 0.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: selected ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: AppConstants.animFast,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: selected ? Colors.white : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: AppColors.accent)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
