import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_button.dart';
import '../../../../core/widgets/ifix_text_field.dart';
import '../../logic/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(_phoneCtrl.text, _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo'))));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دخول الفني'),
          leading: IconButton(
            onPressed: () => context.go(AppRoutes.welcome),
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.engineering_rounded, color: AppColors.accent, size: 48),
                  ),
                ),
                const SizedBox(height: 32),
                Text('مرحباً بك مجدداً!', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text('أدخل بياناتك للمتابعة وتقديم خدماتك للعملاء', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 32),
                IFixTextField(
                  hint: '09xxxxxxxx',
                  label: 'رقم الجوال',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 9 ? 'رقم جوال غير صالح' : null,
                ),
                const SizedBox(height: AppConstants.spacingMD),
                IFixTextField(
                  hint: 'كلمة المرور',
                  label: 'كلمة المرور',
                  controller: _passCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 6 ? 'كلمة المرور قصيرة' : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return IFixButton(
                      label: 'تسجيل الدخول',
                      onTap: _onLogin,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'Cairo')),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('سجل كفني جديد', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
