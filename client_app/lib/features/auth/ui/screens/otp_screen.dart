import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import 'package:ifix_client/features/auth/manager/auth_cubit.dart';
import 'package:ifix_client/features/auth/manager/auth_states.dart';
import 'package:ifix_client/features/home/ui/screens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final bool isRegister;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.isRegister,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color tertiaryColor = Color(0xFF2979FF);
  static const Color borderColor = Color(0xFF30363D);
  static const Color surfaceColor = Colors.white;
  static const Color shadowColor = Color(0x0A3A302A);
  static const Color textColor = Color(0xFFF0F6FC);

  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is VerifyOtpErrorState) {
            context.showOverlaySnackBar(
              message: state.error,
              type: Error(),
              position: SnackPosition.top,
            );
          } else if (state is VerifyResetCodeErrorState) {
            context.showOverlaySnackBar(
              message: state.error,
              type: Error(),
              position: SnackPosition.top,
            );
          } else if (state is ResendOtpErrorState) {
            context.showOverlaySnackBar(
              message: state.error,
              type: Error(),
              position: SnackPosition.top,
            );
          } else if (state is ForgotPasswordErrorState) {
            context.showOverlaySnackBar(
              message: state.error,
              type: Error(),
              position: SnackPosition.top,
            );
          } else if (state is VerifyOtpSuccessState) {
            context.showOverlaySnackBar(
              message: 'تم التحقق وتفعيل الحساب بنجاح',
              type: Success(),
              position: SnackPosition.top,
            );
            context.pushAndRemoveUntil(
              const HomeScreen(),
              (route) => false,
            );
          } else if (state is VerifyResetCodeSuccessState) {
            context.pushReplacement(
              ResetPasswordScreen(
                phone: widget.phone,
                otpCode: otpController.text.trim(),
              ),
            );
          } else if (state is ResendOtpSuccessState ||
              state is ForgotPasswordSuccessState) {
            context.showOverlaySnackBar(
              message: 'تم إعادة إرسال رمز التحقق بنجاح',
              type: Success(),
              position: SnackPosition.top,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is VerifyOtpLoadingState ||
              state is VerifyResetCodeLoadingState;

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
                          'إدخال رمز التحقق',
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
                          'أدخل الرمز المكون من 4 أرقام المرسل إلى الهاتف\n${widget.phone}',
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
                                controller: otpController,
                                label: 'رمز التحقق (OTP)',
                                hintText: '1234',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 40),

                              PrimaryButton(
                                text: 'تأكيد الرمز',
                                isLoading: isLoading,
                                onPressed: () {
                                  if (otpController.text.trim().isEmpty) {
                                    context.showOverlaySnackBar(
                                      message: 'الرجاء إدخال رمز التحقق',
                                      type: Error(),
                                      position: SnackPosition.top,
                                    );
                                    return;
                                  }
                                  if (widget.isRegister) {
                                    context.read<AuthCubit>().verifyOtp(
                                      phone: widget.phone,
                                      otpCode: otpController.text.trim(),
                                    );
                                  } else {
                                    context.read<AuthCubit>().verifyResetCode(
                                      phone: widget.phone,
                                      otpCode: otpController.text.trim(),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'لم يصلك الرمز؟',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (widget.isRegister) {
                                        context.read<AuthCubit>().resendOtp(
                                          phone: widget.phone,
                                        );
                                      } else {
                                        context.read<AuthCubit>().forgotPassword(
                                          phone: widget.phone,
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'إعادة الإرسال',
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



