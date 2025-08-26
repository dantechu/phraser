import 'dart:async';

import 'package:ai_interactions/ai_interactions.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:coins/coins.dart';
import 'package:core/core.dart';
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

void main() async{

  runZonedGuarded( () async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initApp();
    runApp(const MyApp());
  } ,
    (error, stack) =>
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}


Future<void> _initApp() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Firebase.initializeApp();
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
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  AppConfigService.instance.init();
  initializeApplovinMAX();
}


Future<void> initializeApplovinMAX() async {
  try {
    Map? configuration = await AppLovinMAX.initialize('MEtWbKQhnD0RV--92OVfkch9qIpf8efqhgm0MQe018hI8NX-5U4H4bBNhWUmM4aTO2DqJ2La-v2_zG3IDIZQo8');
    if (configuration != null) {
      debugPrint("AppLovinMAX Initialized:");
    }
  } catch (e) {
    debugPrint('Error in initializing AppLovinMAX SDK : $e');
  }
}


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

