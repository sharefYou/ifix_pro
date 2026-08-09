import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import 'package:ifix_client/features/auth/manager/auth_cubit.dart';
import 'package:ifix_client/features/auth/manager/auth_states.dart';
import 'package:ifix_client/features/home/ui/screens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Exact Colors from design.md
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color tertiaryColor = Color(0xFF1565C0);
  static const Color borderColor = Color(0xFFDDE4EF);

  static const Color surfaceColor = Colors.white;
  static const Color shadowColor = Color(0x0A3A302A);
  static const Color textColor = Color(0xFF1A2332);

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is LoginErrorState) {
            context.showOverlaySnackBar(
              message: state.error,
              type: Error(),
              position: SnackPosition.top,
            );
          } else if (state is LoginSuccessState) {
            context.showOverlaySnackBar(
              message: 'تم تسجيل الدخول بنجاح',
              type: Success(),
              position: SnackPosition.top,
            );
            context.pushAndRemoveUntil(
              const HomeScreen(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: backgroundColor,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 48.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Headline
                        const Text(
                          'مرحباً بعودتك',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'قم بتسجيل الدخول للمتابعة إلى حسابك',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 56),

                        // Card
                        Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: borderColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 24,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                controller: phoneController,
                                label: "رقم الهاتف",
                                hintText: "+966501234567",
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                controller: passwordController,
                                label: 'كلمة المرور',
                                hintText: '••••••••',
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                              ),
                              const SizedBox(height: 12),

                              // Forgot Password Link
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: TextButton(
                                  onPressed: () {
                                    context.push(const ForgotPasswordScreen());
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: tertiaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Primary Button
                              PrimaryButton(
                                text: 'تسجيل الدخول',
                                isLoading: state is LoginLoadingState,
                                onPressed: () {
                                  if (phoneController.text.trim().isEmpty ||
                                      passwordController.text.isEmpty) {
                                    context.showOverlaySnackBar(
                                      message: 'الرجاء تعبئة جميع الحقول',
                                      type: Error(),
                                      position: SnackPosition.top,
                                    );
                                    return;
                                  }
                                  context.read<AuthCubit>().login(
                                    phone: phoneController.text.trim(),
                                    password: passwordController.text,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Secondary Button
                              SecondaryButton(
                                text: 'إنشاء حساب جديد',
                                onPressed: () {
                                  context.push(const RegisterScreen());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



