import 'package:dio/dio.dart';
import '../../../../core/api/dio_factory.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('login', data: {
        'phone': phone,
        'password': password,
      });

      if (response.data['status'] == true) {
        final token = response.data['data']['token'];
        await DioFactory.saveToken(token);
        return response.data;
      } else {
        throw response.data['message'] ?? 'Login failed';
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Connection error';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int cityId,
    required String specialty,
    required String idPhoto,
    required String avatar,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'city_id': cityId,
        'specialty': specialty,
        'id_photo': idPhoto,
        'avatar': avatar,
        'role': 'tech',
      });

      if (response.data['status'] == true) {
        final token = response.data['data']['token'];
        await DioFactory.saveToken(token);
        return response.data;
      } else {
        throw response.data['message'] ?? 'Registration failed';
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Connection error';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post('logout');
    } finally {
      await DioFactory.deleteToken();
    }
  }
}
