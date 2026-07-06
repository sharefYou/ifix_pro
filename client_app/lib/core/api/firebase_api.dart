// import 'dart:async';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:ifix_client/core/helpers/cache_helper.dart';
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Secure headless background notification processing
// }
//
// class FirebaseAPI {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   static Future<void> initPushNotifications() async {
//     final settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//       if (kDebugMode) {
//         final token = await _firebaseMessaging.getToken();
//         debugPrint('FCM Token: $token');
//       }
//
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         // Handle foreground notifications securely
//       });
//     }
//   }
//
//   static Future<String?> getDeviceToken() async {
//     try {
//       final token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         await CacheHelper.saveData(key: 'fcm_token', value: token);
//       }
//       return token;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   static Future<void> subscribeToCustomerTopic(String localeCode) async {
//     await _firebaseMessaging.subscribeToTopic('customers_$localeCode');
//   }
//
//   static Future<void> logoutAndUnsubscribe() async {
//     await _firebaseMessaging.deleteToken();
//   }
// }



