import 'package:flutter/material.dart';
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

  final amountController = TextEditingController();
  double selectedPreset = 100.0;

  @override
  void initState() {
    super.initState();
    amountController.text = '100';
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('شحن رصيد المحفظة', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
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
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اختر أو أدخل المبلغ المراد شحنه (ريال):', style: TextStyle(fontSize: 14, color: textColor)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [50.0, 100.0, 200.0, 500.0].map((preset) {
                    final isSel = selectedPreset == preset;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedPreset = preset;
                          amountController.text = preset.toInt().toString();
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? tertiaryColor : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          preset.toInt().toString(),
                          style: TextStyle(color: isSel ? Colors.white : textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'مبلغ الشحن',
                    suffixText: 'ريال',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null) {
                      setState(() => selectedPreset = parsed);
                    }
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
                              final amount = double.tryParse(amountController.text.trim()) ?? 0;
                              if (amount > 0) {
                                context.read<WalletCubit>().topUpWallet(amount);
                              }
                            },
                    child: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('إتمام الشحن الآن', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
