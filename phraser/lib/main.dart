import 'dart:async';
import 'package:ai_interactions/ai_interactions.dart';
import 'package:coins/coins.dart';
import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phraser/screens/notification_settings/notification_helper.dart';
import 'package:phraser/screens/notification_settings/service/notifications_service.dart';
import 'package:phraser/theme/theme_controller.dart';
import 'package:phraser/theme/theme_styles.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/app_config_service.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/helper/get_di.dart' as di;

import 'payments/view_model/in_app_purchase_view_model.dart';

// Global variable to store notification that launched the app
NotificationAppLaunchDetails? _launchNotificationDetails;

// Getter to access launch notification from anywhere in the app
NotificationAppLaunchDetails? getLaunchNotificationDetails() => _launchNotificationDetails;

// Clear the launch notification after handling it
void clearLaunchNotificationDetails() => _launchNotificationDetails = null;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await _initApp();
  
  runZonedGuarded( () async {
    runApp(const MyApp());
  } ,
    (error, stack) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (e) {
        debugPrint('Failed to record error to Crashlytics: $error');
      }
    });
}


Future<void> _initApp() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase if configuration is missing
  }
  Hive.init(appDocumentDir.path);
  await di.init();
  Get.put(InAppPurchaseViewModel());
  await Preferences.instance.init();
  CoinsPackage.registerDependencies();
  await FloorDB.instance.init();
  AIInteractionsPackage.registerDependencies();
  Get.find<AIInteractionsController>().init(characterPersonality: 'You are an eternally optimistic AI assistant whose main goal is to uplift people\'s spirits. You always focus on the positive aspects and see the silver lining in every situation. Your language is warm, encouraging, and inspiring. Always generate 10 to 15 short quotes of just one or two lines each.', setInitialConversation: []);
  /// initialize local notifications plugin for android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await NotificationHelper.instance.initializeLocalNotifications();
  await NotificationConfigService.instance.initialize();
  
  // Check if app was launched from a notification (cold start)
  _launchNotificationDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (_launchNotificationDetails?.didNotificationLaunchApp == true) {
    debugPrint('App launched from notification: ${_launchNotificationDetails?.notificationResponse?.payload}');
  }
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  try {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    debugPrint('Failed to set up Crashlytics error handler: $e');
  }
  AppConfigService.instance.init();
 // initializeApplovinMAX();
}


// Future<void> initializeApplovinMAX() async {
//   try {
//     Map? configuration = await AppLovinMAX.initialize('MEtWbKQhnD0RV--92OVfkch9qIpf8efqhgm0MQe018hI8NX-5U4H4bBNhWUmM4aTO2DqJ2La-v2_zG3IDIZQo8');
//     if (configuration != null) {
//       debugPrint("AppLovinMAX Initialized:");
//     }
//   } catch (e) {
//     debugPrint('Error in initializing AppLovinMAX SDK : $e');
//   }
// }


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Phraser',
      theme: ThemeStyles.lightTheme,
      darkTheme: ThemeStyles.darkTheme,
      themeMode: ThemeController().themeMode,
      getPages: RouteHelper.routes,
      initialRoute: RouteHelper.splashScreen,
    );
  }
}

GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

