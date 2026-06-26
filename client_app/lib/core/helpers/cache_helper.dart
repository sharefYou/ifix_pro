import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheHelper {
  static late FlutterSecureStorage storage;

  static void init() {
    const androidOptions = AndroidOptions();

    storage = const FlutterSecureStorage(aOptions: androidOptions);
  }

  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    return await storage.write(key: key, value: value?.toString());
  }

  static Future<dynamic> getData({required String key}) async {
    return await storage.read(key: key);
  }

  static Future<dynamic> deleteData() async {
    return await storage.deleteAll();
  }
}
