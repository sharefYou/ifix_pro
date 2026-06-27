import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/core/helpers/cache_helper.dart';
import 'package:ifix_client/main.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHelper {
  static Dio? dio;

  static void initialDio({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseURL,
        receiveDataWhenStatusError: true,
        headers: {'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        followRedirects: true,
      ),
    );

    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          final context = navigatorKey.currentContext;
          final lang = context != null && EasyLocalization.of(context) != null
              ? EasyLocalization.of(context)!.locale.languageCode
              : 'en';
          options.headers['Accept-Language'] = lang;
          options.headers['X-App-Locale'] = lang;

          final token = await CacheHelper.getData(key: 'token');
          if (token != null && token.toString().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await CacheHelper.deleteData();
            // Token revoked or expired; trigger app logout flow
          }
          return handler.next(error);
        },
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

  static void updateBaseUrl(String newBaseUrl) {
    dio?.options.baseUrl = newBaseUrl;
  }

  static Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return await dio!.get(endPoint, queryParameters: query, options: options);
  }

  static Future<Response> postData({
    required String endPoint,
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    void Function(int count, int total)? onSendProgress,
  }) async {
    return await dio!.post(
      endPoint,
      data: data,
      queryParameters: query,
      options: options,
      onSendProgress: onSendProgress,
    );
  }

  static Future<Response> putData({
    required String endPoint,
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    void Function(int count, int total)? onSendProgress,
  }) async {
    return await dio!.put(
      endPoint,
      data: data,
      queryParameters: query,
      options: options,
      onSendProgress: onSendProgress,
    );
  }

  static Future<Response> deleteData({
    required String endPoint,
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return await dio!.delete(
      endPoint,
      data: data,
      queryParameters: query,
      options: options,
    );
  }
}
