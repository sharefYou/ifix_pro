// import 'dart:async';
// import 'dart:developer';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:fx_signals/core/helpers/cache_helper.dart';
// import 'package:fx_signals/core/helpers/constants.dart';
// import 'package:fx_signals/core/themes/colors_manager.dart';
// import 'package:fx_signals/main.dart';
// import 'package:overlay_support/overlay_support.dart';
//
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   if (message.data.containsKey('signal_id') ||
//       message.data.containsKey('type')) {
//     CacheHelper.init();
//     await CacheHelper.saveData(key: AppConstants.kSignalsTimer, value: 0);
//   }
// }
//
// class FirebaseAPI {
//   static final _firebaseMessaging = FirebaseMessaging.instance;
//
//   static final StreamController<void> _signalNotificationController =
//       StreamController<void>.broadcast();
//
//   static Stream<void> get onSignalNotification =>
//       _signalNotificationController.stream;
//
//   static void handleMessage(RemoteMessage? message) {
//     if (message == null || message.notification == null) return;
//     if (message.data.containsKey('signal_id') ||
//         message.data.containsKey('type')) {
//       CacheHelper.saveData(key: AppConstants.kSignalsTimer, value: 0);
//       _signalNotificationController.add(null);
//     }
//     showSimpleNotification(
//       background: ColorsManager.green,
//       position: NotificationPosition.top,
//       contentPadding: const EdgeInsets.all(8),
//       leading: const Icon(Icons.notifications),
//       subtitle: Text(message.notification!.body!),
//       Text(
//         message.notification!.title!,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//       ),
//     );
//   }
//
//   static Future<void> printFCM() async =>
//       log(await _firebaseMessaging.getToken() ?? "NULL");
//
//   static Future initPushNotification() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//     await FirebaseMessaging.instance.subscribeToTopic('globalstopic');
//     _firebaseMessaging.getInitialMessage().then(handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//     FirebaseMessaging.onMessage.listen(handleMessage);
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//   }
//
//   static void subscribeToTopic() {
//     final context = navigatorKey.currentContext;
//     if (context == null) return;
//     switch (context.locale.languageCode) {
//       case 'ar':
//         _firebaseMessaging.subscribeToTopic(AppConstants.kGeneralTopicAR);
//         _firebaseMessaging.subscribeToTopic(AppConstants.kSignalsTopicAR);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kGeneralTopicEN);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kSignalsTopicEN);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kGeneralTopicTR);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kSignalsTopicTR);
//       case 'en':
//         _firebaseMessaging.subscribeToTopic(AppConstants.kGeneralTopicEN);
//         _firebaseMessaging.subscribeToTopic(AppConstants.kSignalsTopicEN);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kGeneralTopicAR);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kSignalsTopicAR);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kGeneralTopicTR);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kSignalsTopicTR);
//       case 'tr':
//         _firebaseMessaging.subscribeToTopic(AppConstants.kGeneralTopicTR);
//         _firebaseMessaging.subscribeToTopic(AppConstants.kSignalsTopicTR);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kGeneralTopicEN);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kSignalsTopicEN);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kGeneralTopicAR);
//         _firebaseMessaging.unsubscribeFromTopic(AppConstants.kSignalsTopicAR);
//     }
//   }
//
//   static Future<void> initNotification() async {
//     await _firebaseMessaging.requestPermission(
//       badge: true,
//       alert: true,
//       sound: true,
//       provisional: false,
//       announcement: false,
//       carPlay: false,
//     );
//     initPushNotification();
//   }
// }
