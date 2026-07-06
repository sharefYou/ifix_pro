import 'package:dio/dio.dart';
import '../../../../core/api/dio_factory.dart';
import '../../../../core/errors/error_handler.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('login', data: {
        'phone': phone,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await DioFactory.saveToken(token);
        return data;
      } else {
        throw data['message'] ?? 'Login failed';
      }
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String city,
    required double lat,
    required double lng,
    required String idDocumentPath,
    required List<int> serviceIds,
  }) async {
    try {
      final dio = await DioFactory.getDio();

      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'city': city,
        'lat': lat,
        'lng': lng,
        'id_document': await MultipartFile.fromFile(idDocumentPath),
      });

      for (final id in serviceIds) {
        formData.fields.add(MapEntry('service_ids[]', id.toString()));
      }

      final response = await dio.post('register', data: formData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otpCode) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('verify-otp', data: {
        'phone': phone,
        'otp_code': otpCode,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await DioFactory.saveToken(token);
        return data;
      } else {
        throw data['message'] ?? 'OTP verification failed';
      }
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<Map<String, dynamic>> resendOtp(String phone) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('resend-otp', data: {
        'phone': phone,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<void> logout() async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post('logout');
    } catch (e) {
      // Ignore network errors on logout
    } finally {
      await DioFactory.deleteToken();
    }
  }
}
