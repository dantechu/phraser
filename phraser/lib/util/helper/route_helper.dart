
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:phraser/screens/ai_quotes/chat_view.dart';
import 'package:phraser/screens/ai_quotes/chat_view.dart';
import 'package:phraser/screens/categories_list_screen.dart';
import 'package:phraser/screens/intro/introduction_screen.dart';
import 'package:phraser/screens/notification_settings/notification_settings.dart';
import 'package:phraser/screens/phraser_view.dart';
import 'package:phraser/screens/settings/settings_screen.dart';
import 'package:phraser/screens/theme/phraser_theme_list_screen.dart';

import '../../screens/splash_screen.dart';
import '../../screens/initial_data_loading_screen.dart';
import '../../screens/in_app_purchase/preimum_app_screen.dart';

class RouteHelper {


  static const String categoriesListScreen = '/categories_list_screen';
  static const String introductionScreen = '/introduction_screen';
  static const String phraserScreen = '/phraser_screen';
  static const String settingsScreen = '/settings_screen';
  static const String phraserThemeListScreen = '/phraser_theme_list_screen';
  static const String splashScreen = '/';
  static const String chatScreen = '/chatScreen';
  static const String initialDataLoadingScreen = '/initial_data_loading_screen';
  static const String premiumAppScreen = '/premium_app_screen';


  static String categoriesListRoute () => categoriesListScreen;
  static String introductionRoute () => introductionScreen;
  static String phraserRoute () => phraserScreen;
  static String settingsRoute () => settingsScreen;
  static String splashRoute () => splashScreen;
  static String phraserThemeListRoute () => phraserThemeListScreen;
  static String chatScreenRoute () => chatScreen;
  static String initialDataLoadingRoute () => initialDataLoadingScreen;
  static String premiumAppRoute () => premiumAppScreen;

  static List<GetPage> routes = [
    GetPage(name: categoriesListScreen, page: () => const CategoriesListScreen()),
    GetPage(name: introductionScreen, page: () =>  IntroductionScreen()),
    GetPage(name: phraserScreen, page: () => const PhraserViewScreen()),
    GetPage(name: phraserThemeListScreen, page: () => const PhraserThemeListScreen()),
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: settingsScreen, page: () => const SettingsScreen()),
    GetPage(name: chatScreen, page: () =>  ChatScreen()),
    GetPage(name: initialDataLoadingScreen, page: () => const InitialDataLoadingScreen()),
    GetPage(name: premiumAppScreen, page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      final showCloseButton = args?['showCloseButton'] ?? false;
      return PremiumAppScreen(showCloseButton: showCloseButton);
    }),
  ];
}