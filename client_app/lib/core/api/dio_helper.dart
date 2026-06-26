import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/main.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHelper {
  static Dio? dio;

  static void initialDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseURL,
        receiveDataWhenStatusError: true,
        headers: {'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
        followRedirects: true,
      ),
    );

    if (kDebugMode) {
      dio?.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          requestHeader: true,
          responseHeader: true,
          responseBody: true,
        ),
      );
    }
  }

  static Map<String, dynamic> _buildHeaders({String? token}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-App-Locale': EasyLocalization.of(
        navigatorKey.currentContext!,
      )!.locale.languageCode,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    dio!.options.headers = _buildHeaders(token: token);
    return await dio!.get(endPoint, queryParameters: query);
  }

  static Future<Response> postData({
    required String endPoint,
    Object? data,
    Map<String, dynamic>? query,
    String? token,
    void Function(int count, int total)? onSendProgress,
  }) async {
    dio!.options.headers = _buildHeaders(token: token);
    return await dio!.post(
      endPoint,
      data: data,
      queryParameters: query,
      onSendProgress: onSendProgress,
    );
  }

  static Future<Response> putData({
    required String endPoint,
    Object? data,
    Map<String, dynamic>? query,
    String? token,
    void Function(int count, int total)? onSendProgress,
  }) async {
    dio!.options.headers = _buildHeaders(token: token);
    return await dio!.put(
      endPoint,
      data: data,
      queryParameters: query,
      onSendProgress: onSendProgress,
    );
  }

  static Future<Response> deleteData({
    required String endPoint,
    Object? data,
    Map<String, dynamic>? query,
    String? token,
    void Function(int count, int total)? onSendProgress,
  }) async {
    dio!.options.headers = _buildHeaders(token: token);
    return await dio!.delete(endPoint, data: data, queryParameters: query);
  }
}
