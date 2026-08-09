import '../../../core/api/dio_factory.dart';

class CommonRepository {
  Future<List<dynamic>> getCities() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('cities');
      return response.data['data'];
    } catch (e) {

      throw e.toString();
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('categories');
      return response.data['data'];
    } catch (e) {
      throw e.toString();
    }
  }
}
