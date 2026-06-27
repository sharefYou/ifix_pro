import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/error_handler.dart';
import '../data/models/order_model.dart';
import 'orders_states.dart';

class OrdersCubit extends Cubit<OrdersStates> {
  OrdersCubit() : super(OrdersInitialState());

  List<OrderModel> myOrders = [];

  Future<void> fetchMyOrders() async {
    emit(OrdersLoadingState());
    try {
      // Assuming customer orders can be fetched or filtered
      final response = await DioHelper.getData(endPoint: ApiConstants.orders);
      myOrders = [];
      final data = response.data['data'] ?? response.data['orders'];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            myOrders.add(OrderModel.fromJson(item));
          }
        }
      }
      emit(OrdersLoadedState(myOrders));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(OrdersErrorState(error));
    }
  }

  Future<void> createOrder({
    required int serviceId,
    required String visitType,
    required String visitDate,
    String? notes,
    required String paymentMethod,
    required double totalAmount,
  }) async {
    emit(CreateOrderLoadingState());
    try {
      final response = await DioHelper.postData(
        endPoint: ApiConstants.orders,
        data: {
          'service_id': serviceId,
          'visit_type': visitType,
          'visit_date': visitDate,
          'notes': notes ?? '',
          'payment_method': paymentMethod,
          'total_amount': totalAmount,
        },
      );
      final newOrder = OrderModel.fromJson(response.data['order']);
      myOrders.insert(0, newOrder);
      emit(CreateOrderSuccessState(newOrder));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(CreateOrderErrorState(error));
    }
  }

  Future<void> completeOrder(int orderId) async {
    emit(OrderActionLoadingState());
    try {
      await DioHelper.postData(endPoint: ApiConstants.completeOrder(orderId), data: {});
      emit(OrderActionSuccessState('تم تأكيد اكتمال الطلب بنجاح'));
      await fetchMyOrders();
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(OrderActionErrorState(error));
    }
  }

  Future<void> cancelOrder(int orderId) async {
    emit(OrderActionLoadingState());
    try {
      await DioHelper.postData(endPoint: ApiConstants.cancelOrder(orderId), data: {});
      emit(OrderActionSuccessState('تم إلغاء الطلب بنجاح'));
      await fetchMyOrders();
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(OrderActionErrorState(error));
    }
  }

  Future<void> submitReview({
    required int orderId,
    required int timeRating,
    required int qualityRating,
    required int cleanlinessRating,
  }) async {
    emit(OrderActionLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.addReview(orderId),
        data: {
          'time_rating': timeRating,
          'quality_rating': qualityRating,
          'cleanliness_rating': cleanlinessRating,
        },
      );
      emit(OrderActionSuccessState('شكراً لك، تم إرسال تقييمك بنجاح'));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(OrderActionErrorState(error));
    }
  }
}
