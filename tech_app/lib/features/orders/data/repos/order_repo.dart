import '../../../../core/api/dio_factory.dart';
import '../../../../core/errors/error_handler.dart';

class OrderRepository {
  Future<List<dynamic>> getAvailableOrders() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('orders/available');
      return (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<String> acceptOrder(int orderId) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('orders/$orderId/accept');
      final data = response.data as Map<String, dynamic>? ?? {};
      return data['message']?.toString() ?? '';
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<String> completeOrder(int orderId) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('orders/$orderId/complete');
      final data = response.data as Map<String, dynamic>? ?? {};
      return data['message']?.toString() ?? '';
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('orders/my');
      return (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }
}
