import 'package:dio/dio.dart';

class ErrorHandler {
  static String handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstVal = errors.values.first;
            if (firstVal is List && firstVal.isNotEmpty) {
              return firstVal.first.toString();
            } else if (firstVal != null) {
              return firstVal.toString();
            }
          }
        }
        final message = data['message'] ?? data['error'] ?? data['detail'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data;
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Server took too long to respond.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Server took too long to respond.';
      case DioExceptionType.badResponse:
        return 'Server returned an unexpected response.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Network error. Please check your connection.';
      case DioExceptionType.unknown:
      default:
        return 'Unexpected network error occurred.';
    }
  }

  static String handleGeneralError(dynamic e) {
    if (e is DioException) return handleDioError(e);
    return e.toString().replaceAll('Exception: ', '');
  }
}
