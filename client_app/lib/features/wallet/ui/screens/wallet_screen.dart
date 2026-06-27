import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/wallet_model.dart';
import '../../manager/wallet_cubit.dart';
import '../../manager/wallet_states.dart';
import '../widgets/top_up_dialog.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().fetchWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: const Text('المحفظة الإلكترونية', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocBuilder<WalletCubit, WalletStates>(
          builder: (context, state) {
            final cubit = context.read<WalletCubit>();
            if (state is WalletLoadingState) {
              return const Center(child: CircularProgressIndicator(color: tertiaryColor));
            } else if (state is WalletErrorState && cubit.currentWallet == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error, style: const TextStyle(color: textColor)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor),
                      onPressed: () => cubit.fetchWalletData(),
                      child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            final wallet = cubit.currentWallet ?? WalletModel(id: 0, availableBalance: 0, heldBalance: 0);
            final transactions = cubit.transactions;

            return RefreshIndicator(
              color: tertiaryColor,
              onRefresh: () => cubit.fetchWalletData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3A302A), Color(0xFF5A4D44)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: textColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الرصيد المتاح للاستخدام', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                            const Icon(Icons.account_balance_wallet, color: tertiaryColor, size: 28),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${wallet.availableBalance} ريال',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        if (wallet.heldBalance > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text('رصيد معلق للطلبات: ${wallet.heldBalance} ريال', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tertiaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('شحن المحفظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BlocProvider.value(
                                  value: context.read<WalletCubit>(),
                                  child: const TopUpDialog(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('سجل العمليات السابقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 16),
                  if (transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Text('لا توجد عمليات مسجلة في محفظتك بعد', style: TextStyle(color: textColor.withValues(alpha: 0.5))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final tx = transactions[idx];
                        final isDep = tx.type == 'deposit' || tx.type == 'release';
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: (isDep ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                child: Icon(isDep ? Icons.arrow_downward : Icons.arrow_upward, color: isDep ? Colors.green : Colors.red, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_txTypeLabel(tx.type), style: const TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                    if (tx.createdAt != null) ...[
                                      const SizedBox(height: 4),
                                      Text(tx.createdAt!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '${isDep ? '+' : '-'}${tx.amount} ريال',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDep ? Colors.green : Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _txTypeLabel(String type) {
    switch (type) {
      case 'deposit':
        return 'إيداع رصيد';
      case 'withdrawal':
        return 'سحب رصيد';
      case 'hold':
        return 'حجز رصيد لطلب';
      case 'release':
        return 'إرجاع رصيد محجوز';
      default:
        return type;
    }
  }
}
