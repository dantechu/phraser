
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:phraser/screens/ai_quotes/chat_view.dart';
import 'package:phraser/screens/ai_quotes/chat_view.dart';
import 'package:phraser/screens/categories_list_screen.dart';
import 'package:phraser/screens/intro/introduction_screen.dart';
import 'package:phraser/screens/notification_settings/notification_settings.dart';
import 'package:phraser/screens/phraser_view.dart';
import 'package:phraser/screens/settings/settings_screen.dart';
import 'package:phraser/screens/theme/phraser_theme_list_screen.dart';

import '../../screens/splash_screen.dart';

class RouteHelper {


  static const String categoriesListScreen = '/categories_list_screen';
  static const String introductionScreen = '/introduction_screen';
  static const String phraserScreen = '/phraser_screen';
  static const String settingsScreen = '/settings_screen';
  static const String phraserThemeListScreen = '/phraser_theme_list_screen';
  static const String splashScreen = '/';
  static const String chatScreen = '/chatScreen';


  static String categoriesListRoute () => categoriesListScreen;
  static String introductionRoute () => introductionScreen;
  static String phraserRoute () => phraserScreen;
  static String settingsRoute () => settingsScreen;
  static String splashRoute () => splashScreen;
  static String phraserThemeListRoute () => phraserThemeListScreen;
  static String chatScreenRoute () => chatScreen;

  static List<GetPage> routes = [
    GetPage(name: categoriesListScreen, page: () => const CategoriesListScreen()),
    GetPage(name: introductionScreen, page: () =>  IntroductionScreen()),
    GetPage(name: phraserScreen, page: () => const PhraserViewScreen()),
    GetPage(name: phraserThemeListScreen, page: () => const PhraserThemeListScreen()),
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: settingsScreen, page: () => const SettingsScreen()),
    GetPage(name: chatScreen, page: () =>  ChatScreen()),
  ];
}