import 'package:phraser/util/preferences.dart';

class PreferencesUtil {
  
  static Future<void> setSelectedRegion(String? region) async {
    Preferences.instance.selectedRegion = region;
  }
  
  static String? getSelectedRegion() {
    return Preferences.instance.selectedRegion;
  }
  
  static Future<void> setIsPremiumApp(bool value) async {
    Preferences.instance.isPremiumApp = value;
  }
  
  static bool getIsPremiumApp() {
    return Preferences.instance.isPremiumApp;
  }
  
  static Future<void> setCurrentMood(String? mood) async {
    Preferences.instance.currentMood = mood;
  }
  
  static String? getCurrentMood() {
    return Preferences.instance.currentMood;
  }
  
  static Future<void> setCurrentMoodIntensity(String? intensity) async {
    Preferences.instance.currentMoodIntensity = intensity;
  }
  
  static String? getCurrentMoodIntensity() {
    return Preferences.instance.currentMoodIntensity;
  }
  
  static Future<void> setMoodFilterEnabled(bool enabled) async {
    Preferences.instance.isMoodFilterEnabled = enabled;
  }
  
  static bool getMoodFilterEnabled() {
    return Preferences.instance.isMoodFilterEnabled;
  }
  
  static Future<void> setCurrentPhraserPosition(int position) async {
    Preferences.instance.currentPhraserPosition = position;
  }
  
  static int getCurrentPhraserPosition() {
    return Preferences.instance.currentPhraserPosition;
  }
  
  static Future<void> setTextThemePosition(int position) async {
    Preferences.instance.textThemePosition = position;
  }
  
  static int getTextThemePosition() {
    return Preferences.instance.textThemePosition;
  }
}