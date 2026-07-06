import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/custom_order_model.dart';
import '../data/models/bid_model.dart';
import '../data/repos/custom_orders_repo.dart';

part 'custom_orders_state.dart';

class CustomOrdersCubit extends Cubit<CustomOrdersState> {
  final CustomOrdersRepository _repo;

  CustomOrdersCubit(this._repo) : super(CustomOrdersInitial());

  Future<void> loadData() async {
    emit(CustomOrdersLoading());
    try {
      final available = await _repo.getAvailableRequests();
      final myBids = await _repo.getMyBids();
      emit(CustomOrdersLoaded(availableRequests: available, myBids: myBids));
    } catch (e) {
      emit(CustomOrdersError(e.toString()));
    }
  }

  Future<void> submitBid({
    required int customRequestId,
    required double price,
    double? laborCost,
    double? partsCost,
    String? notes,
  }) async {
    emit(CustomOrderActionLoading());
    try {
      await _repo.submitBid(
        customRequestId: customRequestId,
        price: price,
        laborCost: laborCost,
        partsCost: partsCost,
        notes: notes,
      );
      emit(const CustomOrderActionSuccess('تم تقديم عرض السعر بنجاح'));
      await loadData();
    } catch (e) {
      emit(CustomOrdersError(e.toString()));
    }
  }

  Future<void> submitCounterOffer({
    required int bidId,
    required double counterPrice,
    String? counterNotes,
  }) async {
    emit(CustomOrderActionLoading());
    try {
      await _repo.submitCounterOffer(
        bidId: bidId,
        counterPrice: counterPrice,
        counterNotes: counterNotes,
      );
      emit(const CustomOrderActionSuccess('تم إرسال العرض المقابل للعميل'));
      await loadData();
    } catch (e) {
      emit(CustomOrdersError(e.toString()));
    }
  }

  Future<void> acceptCounterOffer(int bidId) async {
    emit(CustomOrderActionLoading());
    try {
      await _repo.acceptCounterOffer(bidId);
      emit(const CustomOrderActionSuccess('تم قبول عرض العميل بنجاح، بانتظار تأكيد الطلب'));
      await loadData();
    } catch (e) {
      emit(CustomOrdersError(e.toString()));
    }
  }
}
