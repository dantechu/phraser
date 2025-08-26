// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:phraser/consts/const_objects.dart';
//
// class NotificationHelper {
//   static final NotificationHelper _instance = NotificationHelper._();
//   static NotificationHelper get instance => _instance;
//   NotificationHelper._();
//
//   Future<void> showSchedualNotification() async {
//
//   }
//
//   Future<bool> checkSchedualNotificationExists() async {
//     final List<PendingNotificationRequest> pendingNotificationRequests =
//         await flutterLocalNotificationsPlugin.pendingNotificationRequests();
//     for (final notify in pendingNotificationRequests) {
//       if (notify.id == 1) {
//         return true;
//       }
//     }
//     return false;
//   }
// }
//
//
//
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   description: 'This channel is used for important notifications.',
//   // description
//   importance: Importance.high,
// );
// Future<void> initNotifications() async {
//   const initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//   const initialzationSettingsIOS = DarwinInitializationSettings();
//   const initializationSettings = InitializationSettings(android: initialzationSettingsAndroid, iOS: initialzationSettingsIOS);
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: onLocalNotificationSelect,
//       onDidReceiveBackgroundNotificationResponse: onLocalNotificationSelect); //onSelectNotification: onLocalNotificationSelect
//
//
// }
//
// void onLocalNotificationSelect(NotificationResponse payload) {
//   //TODO: integrate local notification routing from payload
// }
//
//
