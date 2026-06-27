import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../data/repos/order_repo.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repo;

  OrderCubit(this._repo) : super(OrderInitial());

  String _getLocalizedFallback(String key) {
    final l10n = lookupAppLocalizations(ui.PlatformDispatcher.instance.locale);
    switch (key) {
      case 'accept':
        return l10n.acceptOrder;
      case 'complete':
        return l10n.completeOrder;
      default:
        return '';
    }
  }

  Future<void> getAvailableOrders() async {
    emit(OrderLoading());
    try {
      final orders = await _repo.getAvailableOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> getMyOrders() async {
    emit(OrderLoading());
    try {
      final orders = await _repo.getMyOrders();
      emit(MyOrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> acceptOrder(int orderId) async {
    emit(OrderActionLoading());
    try {
      final message = await _repo.acceptOrder(orderId);
      emit(OrderActionSuccess(message.isNotEmpty ? message : _getLocalizedFallback('accept')));
      await getAvailableOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> completeOrder(int orderId) async {
    emit(OrderActionLoading());
    try {
      final message = await _repo.completeOrder(orderId);
      emit(OrderActionSuccess(message.isNotEmpty ? message : _getLocalizedFallback('complete')));
      await getMyOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
