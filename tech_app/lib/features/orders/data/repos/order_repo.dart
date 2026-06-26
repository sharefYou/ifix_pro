import '../../../../core/api/dio_factory.dart';

class OrderRepository {
  Future<List<dynamic>> getAvailableOrders() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('orders/available');
      return response.data['data'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> acceptOrder(int orderId) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post('orders/$orderId/accept');
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> completeOrder(int orderId) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post('orders/$orderId/complete');
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('orders/my');
      return response.data['data'];
    } catch (e) {
      throw e.toString();
    }
  }
}
