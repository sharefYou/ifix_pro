part of 'custom_orders_cubit.dart';

abstract class CustomOrdersState extends Equatable {
  const CustomOrdersState();

  @override
  List<Object?> get props => [];
}

class CustomOrdersInitial extends CustomOrdersState {}

class CustomOrdersLoading extends CustomOrdersState {}

class CustomOrdersLoaded extends CustomOrdersState {
  final List<CustomOrderModel> availableRequests;
  final List<BidModel> myBids;

  const CustomOrdersLoaded({required this.availableRequests, required this.myBids});

  @override
  List<Object?> get props => [availableRequests, myBids];
}

class CustomOrderActionLoading extends CustomOrdersState {}

class CustomOrderActionSuccess extends CustomOrdersState {
  final String message;

  const CustomOrderActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomOrdersError extends CustomOrdersState {
  final String error;

  const CustomOrdersError(this.error);

  @override
  List<Object?> get props => [error];
}
