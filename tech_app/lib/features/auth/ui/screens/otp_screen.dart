import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../logic/auth_cubit.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().verifyOtp(widget.phone, _otpCtrl.text.trim());
  }

  void _onResend() {
    context.read<AuthCubit>().resendOtp(widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpVerifiedSuccess || state is AuthSuccess) {
          context.go(AppRoutes.pendingApproval);
        } else if (state is OtpSentSuccess) {
          final msg = state.devOtp != null ? '${state.message} (DEV: ${state.devOtp})' : state.message;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: AppTextStyles.bodyMedium)));
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: AppTextStyles.bodyMedium)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('verify_otp'.tr()),
          leading: IconButton(
            onPressed: () => context.go(AppRoutes.login),
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
                const SizedBox(height: 32),
                Text('enter_otp_code'.tr(), style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text('${'otp_sent_to'.tr()} ${widget.phone}', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'otp_code'.tr(),
                    hintText: '1234',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'required_field'.tr();
                    if (val.trim().length != 4) return 'invalid_otp'.tr();
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onVerify,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                        ),
                        child: Text('verify'.tr(), style: AppTextStyles.labelLarge),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _onResend,
                    child: Text('resend_otp'.tr(), style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
