import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late FlutterSecureStorage secureStorage;
  static late SharedPreferences sharedPreferences;
  static final Map<String, dynamic> _fastUiCache = {};

  static const _sensitiveKeys = {'token', 'fcm_token', 'password', 'refresh_token'};

  static Future<void> init() async {
    const androidOptions = AndroidOptions();
    const iosOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);

    secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static bool _isSensitive(String key) => _sensitiveKeys.contains(key);

  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    final strValue = value?.toString();
    if (_isSensitive(key)) {
      await secureStorage.write(key: key, value: strValue);
    } else {
      _fastUiCache[key] = value;
      if (value is bool) {
        await sharedPreferences.setBool(key, value);
      } else if (value is int) {
        await sharedPreferences.setInt(key, value);
      } else if (value is double) {
        await sharedPreferences.setDouble(key, value);
      } else if (value is String) {
        await sharedPreferences.setString(key, value);
      } else if (strValue != null) {
        await sharedPreferences.setString(key, strValue);
      }
    }
  }

  static Future<dynamic> getData({required String key}) async {
    if (_isSensitive(key)) {
      return await secureStorage.read(key: key);
    }
    if (_fastUiCache.containsKey(key)) {
      return _fastUiCache[key];
    }
    final val = sharedPreferences.get(key);
    if (val != null) _fastUiCache[key] = val;
    return val;
  }

  static Future<void> deleteData({String? key}) async {
    if (key != null) {
      _fastUiCache.remove(key);
      if (_isSensitive(key)) {
        await secureStorage.delete(key: key);
      } else {
        await sharedPreferences.remove(key);
      }
    } else {
      _fastUiCache.clear();
      for (final sKey in _sensitiveKeys) {
        await secureStorage.delete(key: sKey);
      }
      await sharedPreferences.clear();
    }
  }
}



