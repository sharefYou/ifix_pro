import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repos/order_repo.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repo;

  OrderCubit(this._repo) : super(OrderInitial());

  Future<void> getAvailableOrders() async {
    emit(OrderLoading());
    try {
      final orders = await _repo.getAvailableOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> acceptOrder(int orderId) async {
    emit(OrderActionLoading());
    try {
      await _repo.acceptOrder(orderId);
      emit(OrderActionSuccess('تم قبول الطلب بنجاح'));
      getAvailableOrders(); // Refresh list
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
