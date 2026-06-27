import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheHelper {
  static late FlutterSecureStorage secureStorage;
  static final Map<String, dynamic> _fastUiCache = {};

  static const _sensitiveKeys = {'token', 'fcm_token', 'password', 'refresh_token'};

  static Future<void> init() async {
    const androidOptions = AndroidOptions();
    const iosOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);

    secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
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
      await secureStorage.write(key: key, value: strValue);
    }
  }

  static Future<dynamic> getData({required String key}) async {
    if (_isSensitive(key)) {
      return await secureStorage.read(key: key);
    }
    if (_fastUiCache.containsKey(key)) {
      return _fastUiCache[key];
    }
    final val = await secureStorage.read(key: key);
    if (val != null) _fastUiCache[key] = val;
    return val;
  }

  static Future<void> deleteData({String? key}) async {
    if (key != null) {
      _fastUiCache.remove(key);
      await secureStorage.delete(key: key);
    } else {
      for (final sKey in _sensitiveKeys) {
        await secureStorage.delete(key: sKey);
      }
      await secureStorage.delete(key: 'user');
    }
  }
}
