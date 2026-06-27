part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<dynamic> orders;
  OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class MyOrdersLoaded extends OrderState {
  final List<dynamic> orders;
  MyOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderActionLoading extends OrderState {}

class OrderActionSuccess extends OrderState {
  final String message;
  OrderActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
