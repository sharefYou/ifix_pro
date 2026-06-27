import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/custom_request_model.dart';
import '../../manager/custom_requests_cubit.dart';
import '../../manager/custom_requests_states.dart';
import 'create_custom_request_screen.dart';

class MyCustomRequestsScreen extends StatefulWidget {
  const MyCustomRequestsScreen({super.key});

  @override
  State<MyCustomRequestsScreen> createState() => _MyCustomRequestsScreenState();
}

class _MyCustomRequestsScreenState extends State<MyCustomRequestsScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  @override
  void initState() {
    super.initState();
    context.read<CustomRequestsCubit>().fetchMyCustomRequests();
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
          leading: const BackButton(color: textColor),
          title: const Text('طلبات الصيانة الخاصة', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: tertiaryColor),
              onPressed: () => context.push(const CreateCustomRequestScreen()),
            ),
          ],
        ),
        body: BlocBuilder<CustomRequestsCubit, CustomRequestsStates>(
          builder: (context, state) {
            final cubit = context.read<CustomRequestsCubit>();
            final list = cubit.myRequests;

            if (state is CustomRequestsLoadingState) {
              return const Center(child: CircularProgressIndicator(color: tertiaryColor));
            } else if (state is CustomRequestsErrorState && list.isEmpty) {
              return Center(child: Text(state.error, style: const TextStyle(color: textColor)));
            } else if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handyman_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('لم تقم بإنشاء أي طلب صيانة خاص بعد', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('إضافة طلب صيانة مخصص', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () => context.push(const CreateCustomRequestScreen()),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: tertiaryColor,
              onRefresh: () => cubit.fetchMyCustomRequests(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, idx) => _buildRequestCard(list[idx]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(CustomRequestModel req) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مناقصة #${req.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(req.statusArabic, style: const TextStyle(color: tertiaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(req.description, style: const TextStyle(color: textColor, fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (req.visitDate != null) Text('التنفيذ: ${req.visitDate!}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              TextButton.icon(
                icon: const Icon(Icons.local_offer_outlined, size: 16, color: tertiaryColor),
                label: const Text('عرض الأسعار المقدمة', style: TextStyle(color: tertiaryColor, fontWeight: FontWeight.bold)),
                onPressed: () => _showBidsBottomSheet(req.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBidsBottomSheet(int reqId) {
    final cubit = context.read<CustomRequestsCubit>();
    cubit.fetchBids(reqId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<CustomRequestsCubit, CustomRequestsStates>(
              builder: (context, state) {
                if (state is BidsLoadingState) {
                  return const Center(child: CircularProgressIndicator(color: tertiaryColor));
                } else if (state is BidsErrorState) {
                  return Center(child: Text(state.error));
                }
                final bids = cubit.currentBids;
                if (bids.isEmpty) {
                  return const Center(child: Text('لم يقم أي فني بتقديم عروض أسعار لهذا الطلب بعد'));
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('عروض الأسعار المستلمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: bids.length,
                        separatorBuilder: (context, i) => const Divider(),
                        itemBuilder: (context, idx) {
                          final b = bids[idx];
                          return ListTile(
                            leading: const CircleAvatar(backgroundColor: tertiaryColor, child: Icon(Icons.person, color: Colors.white)),
                            title: Text(b.technicianName ?? 'فني صيانة معتمد', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('السعر المعروض: ${b.price} ريال'),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () {
                                cubit.acceptBid(customRequestId: reqId, bidId: b.id, serviceId: 1, visitType: 'home', paymentMethod: 'wallet');
                                Navigator.pop(context);
                              },
                              child: const Text('قبول العرض', style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
