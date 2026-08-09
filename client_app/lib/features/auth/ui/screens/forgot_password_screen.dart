import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import 'package:ifix_client/features/auth/manager/auth_cubit.dart';
import 'package:ifix_client/features/auth/manager/auth_states.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color borderColor = Color(0xFFDDE4EF);
  static const Color surfaceColor = Colors.white;
  static const Color shadowColor = Color(0x0A3A302A);
  static const Color textColor = Color(0xFF1A2332);

  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is ForgotPasswordErrorState) {
            context.showOverlaySnackBar(
              message: state.error,
              type: Error(),
              position: SnackPosition.top,
            );
          } else if (state is ForgotPasswordSuccessState) {
            context.showOverlaySnackBar(
              message: 'تم إرسال رمز التحقق إلى رقم هاتفك',
              type: Success(),
              position: SnackPosition.top,
            );
            context.pushReplacement(
              OtpScreen(phone: state.phone, isRegister: false),
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
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'نسيت كلمة المرور؟',
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
                          'أدخل رقم الهاتف المرتبط بحسابك وسنقوم بإرسال رمز للتحقق',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

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
                                label: 'رقم الهاتف',
                                hintText: '+966501234567',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 40),

                              PrimaryButton(
                                text: 'إرسال رمز التحقق',
                                isLoading: state is ForgotPasswordLoadingState,
                                onPressed: () {
                                  if (phoneController.text.trim().isEmpty) {
                                    context.showOverlaySnackBar(
                                      message: 'الرجاء إدخال رقم الهاتف',
                                      type: Error(),
                                      position: SnackPosition.top,
                                    );
                                    return;
                                  }
                                  context.read<AuthCubit>().forgotPassword(
                                    phone: phoneController.text.trim(),
                                  );
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



