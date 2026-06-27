import '../data/models/order_model.dart';

abstract class OrdersStates {}

class OrdersInitialState extends OrdersStates {}

class OrdersLoadingState extends OrdersStates {}

class OrdersLoadedState extends OrdersStates {
  final List<OrderModel> orders;
  OrdersLoadedState(this.orders);
}

class OrdersErrorState extends OrdersStates {
  final String error;
  OrdersErrorState(this.error);
}

class CreateOrderLoadingState extends OrdersStates {}

class CreateOrderSuccessState extends OrdersStates {
  final OrderModel order;
  CreateOrderSuccessState(this.order);
}

class CreateOrderErrorState extends OrdersStates {
  final String error;
  CreateOrderErrorState(this.error);
}

class OrderActionLoadingState extends OrdersStates {}

class OrderActionSuccessState extends OrdersStates {
  final String message;
  OrderActionSuccessState(this.message);
}

class OrderActionErrorState extends OrdersStates {
  final String error;
  OrderActionErrorState(this.error);
}
