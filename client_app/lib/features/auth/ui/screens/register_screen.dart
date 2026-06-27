import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import 'package:ifix_client/features/auth/manager/auth_cubit.dart';
import 'package:ifix_client/features/auth/manager/auth_states.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color surfaceColor = Colors.white;
  static const Color shadowColor = Color(0x0A3A302A);
  static const Color textColor = Color(0xFF3A302A);

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is RegisterErrorState) {
            context.showOverlaySnackBar(
              message: state.error,
              type: Error(),
              position: SnackPosition.top,
            );
          } else if (state is RegisterSuccessState) {
            context.showOverlaySnackBar(
              message: 'تم إنشاء الحساب بنجاح، يرجى تفعيل رقم الهاتف',
              type: Success(),
              position: SnackPosition.top,
            );
            context.pushReplacement(
              OtpScreen(phone: state.phone, isRegister: true),
            );
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: textColor),
                  onPressed: () => context.pop(),
                ),
              ),
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'أدخل بياناتك للانضمام والاستفادة من خدماتنا',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

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
                                controller: nameController,
                                label: 'الاسم الكامل',
                                hintText: 'أحمد محمد',
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: phoneController,
                                label: 'رقم الهاتف',
                                hintText: '+966501234567',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: emailController,
                                label: 'البريد الإلكتروني',
                                hintText: 'example@email.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: passwordController,
                                label: 'كلمة المرور',
                                hintText: '••••••••',
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                              ),
                              const SizedBox(height: 40),

                              PrimaryButton(
                                text: 'إنشاء حساب',
                                isLoading: state is RegisterLoadingState,
                                onPressed: () {
                                  if (nameController.text.trim().isEmpty ||
                                      phoneController.text.trim().isEmpty ||
                                      emailController.text.trim().isEmpty ||
                                      passwordController.text.isEmpty) {
                                    context.showOverlaySnackBar(
                                      message: 'الرجاء تعبئة جميع الحقول المطلوبة',
                                      type: Error(),
                                      position: SnackPosition.top,
                                    );
                                    return;
                                  }
                                  context.read<AuthCubit>().register(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'لديك حساب بالفعل؟',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    child: const Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: tertiaryColor,
                                      ),
                                    ),
                                  ),
                                ],
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
