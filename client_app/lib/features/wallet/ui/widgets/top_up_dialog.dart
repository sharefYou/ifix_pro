import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../manager/wallet_cubit.dart';
import '../../manager/wallet_states.dart';

class TopUpDialog extends StatefulWidget {
  const TopUpDialog({super.key});

  @override
  State<TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<TopUpDialog> {
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color textColor = Color(0xFF3A302A);

  final codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('شحن رصيد ببطاقة', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        content: BlocConsumer<WalletCubit, WalletStates>(
          listener: (context, state) {
            if (state is TopUpSuccessState) {
              context.showOverlaySnackBar(message: state.message, type: Success());
              context.pop();
            } else if (state is TopUpErrorState) {
              context.showOverlaySnackBar(message: state.error, type: Error());
            }
          },
          builder: (context, state) {
            final isLoading = state is TopUpLoadingState;
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'قم بإدخال رقم بطاقة الشحن المكون من 14 رقماً:',
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                    decoration: InputDecoration(
                      labelText: 'رقم بطاقة الشحن',
                      hintText: 'XXXXXXXXXXXXXX',
                      prefixIcon: const Icon(Icons.credit_card, color: tertiaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: tertiaryColor, width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length != 14) {
                        return 'يجب إدخال 14 رقماً بالضبط';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tertiaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<WalletCubit>().topUpWallet(codeController.text.trim());
                              }
                            },
                      child: isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('شحن الرصيد الآن', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
