import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioFactory {
  static const String _defaultBaseUrl = 'https://sharef.alwaysdata.net/api/v1/technician/';
  static const String _tokenKey = 'auth_token';
  static final _storage = const FlutterSecureStorage();

  static Dio? _dio;

  static void updateBaseUrl(String newUrl) {
    _dio?.options.baseUrl = newUrl;
  }

  static Future<Dio> getDio({String? customBaseUrl}) async {
    if (_dio != null) {
      if (customBaseUrl != null) _dio!.options.baseUrl = customBaseUrl;
      return _dio!;
    }

    _dio = Dio(BaseOptions(
      baseUrl: customBaseUrl ?? _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';

        final prefs = await SharedPreferences.getInstance();
        final lang = prefs.getString('app_language') ?? ui.PlatformDispatcher.instance.locale.languageCode;
        options.headers['Accept-Language'] = lang;
        options.headers['X-App-Locale'] = lang;

        final token = await _storage.read(key: _tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          await deleteToken();
          // Token expired or revoked; trigger app logout navigation
        }
        return handler.next(error);
      },
    ));

    if (kDebugMode) {
      _dio!.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
      ));
    }

    return _dio!;
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
