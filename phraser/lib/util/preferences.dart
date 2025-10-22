import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {

  Preferences._();
  //singleton to access members with out creating class object
  static final Preferences _instance = Preferences._();
  static Preferences get instance => _instance;



  late SharedPreferences? _preferences;

  final String _categoriesKey = 'categories';
  final String _savedCategoriesKey = 'saved_categories';
  final String _firstOpenKey = 'first_open';
  final String _currentPhraserKey = 'current_phraser_position';
  final String _textThemePositionKey = 'text_theme_position';
  final String _premiumAppKey = 'premium_app';
  final String _customNotificationsKey = 'custom_notifications';
  final String _selectedRegionKey = 'selected_region';
  final String _selectedNavigationTabKey = 'selected_navigation_tab';
  final String _currentMoodKey = 'current_mood';
  final String _currentMoodIntensityKey = 'current_mood_intensity';
  final String _moodFilterEnabledKey = 'mood_filter_enabled';
  final String _allQuotesPreloadedKey = 'all_quotes_preloaded';
  final String _initialDataLoadedKey = 'initial_data_loaded';
  final String _lastDataLoadTimestampKey = 'last_data_load_timestamp';
  final String _widgetRefreshIntervalKey = 'widget_refresh_interval';

  //init function to initialized sharedPreferences in main function
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  set isCategoriesPresent(bool value) {
    _preferences!.setBool(_categoriesKey, value);
  }

  set savedCategoryName(String categoriesList) {
    _preferences!.setString(_savedCategoriesKey, categoriesList);
  }

  set customNotifications(String customNotifications) {
    _preferences!.setString(_customNotificationsKey, customNotifications);
  }

  set textThemePosition(int position) {
    _preferences!.setInt(_textThemePositionKey, position);
  }


  set isFirstOpen(bool value) {
    _preferences!.setBool(_firstOpenKey, value);
  }

  set isPremiumApp(bool value) {
    _preferences!.setBool(_premiumAppKey, value);
  }

  set currentPhraserPosition(int position) {
    _preferences!.setInt(_currentPhraserKey, position);
  }

  set selectedRegion(String? region) {
    if(region != null ) {
      _preferences!.setString(_selectedRegionKey, region!);
    }
  }

  set selectedNavigationTab(String tabName) {
    _preferences!.setString(_selectedNavigationTabKey, tabName);
  }

  set currentMood(String? mood) {
    if (mood != null) {
      _preferences!.setString(_currentMoodKey, mood);
    } else {
      _preferences!.remove(_currentMoodKey);
    }
  }

  set currentMoodIntensity(String? intensity) {
    if (intensity != null) {
      _preferences!.setString(_currentMoodIntensityKey, intensity);
    } else {
      _preferences!.remove(_currentMoodIntensityKey);
    }
  }

  set isMoodFilterEnabled(bool enabled) {
    _preferences!.setBool(_moodFilterEnabledKey, enabled);
  }

  set isAllQuotesPreloaded(bool value) {
    _preferences!.setBool(_allQuotesPreloadedKey, value);
  }

  set isInitialDataLoaded(bool value) {
    _preferences!.setBool(_initialDataLoadedKey, value);
  }

  set lastDataLoadTimestamp(int timestamp) {
    _preferences!.setInt(_lastDataLoadTimestampKey, timestamp);
  }

  set widgetRefreshInterval(int minutes) {
    _preferences!.setInt(_widgetRefreshIntervalKey, minutes);
  }

  void setStringList(String key, List<String> value) {
    _preferences!.setStringList(key, value);
  }

  bool get isCategoriesPresent {
    return _preferences!.getBool(_categoriesKey) ?? false;
  }

  bool get isPremiumApp {
    return _preferences!.getBool(_premiumAppKey) ?? false;
  }

  bool get isFirstOpen {
    return _preferences!.getBool(_firstOpenKey) ?? true;
  }

  String get savedCategoryName {
    return _preferences!.getString(_savedCategoriesKey) ?? 'Category';
  }

  String get customNotifications {
    return _preferences!.getString(_customNotificationsKey) ?? jsonEncode(defaultCustomNotificationsData);
  }

  int get currentPhraserPosition {
    return _preferences!.getInt(_currentPhraserKey) ?? 0;
  }

  int get textThemePosition {
    return _preferences!.getInt(_textThemePositionKey) ?? 1;
  }

  String? get selectedRegion {
    return _preferences!.getString(_selectedRegionKey);
  }

  String get selectedNavigationTab {
    return _preferences!.getString(_selectedNavigationTabKey) ?? 'Categories';
  }

  String? get currentMood {
    return _preferences!.getString(_currentMoodKey);
  }

  String? get currentMoodIntensity {
    return _preferences!.getString(_currentMoodIntensityKey);
  }

  bool get isMoodFilterEnabled {
    return _preferences!.getBool(_moodFilterEnabledKey) ?? false;
  }

  bool get isAllQuotesPreloaded {
    return _preferences!.getBool(_allQuotesPreloadedKey) ?? false;
  }

  bool get isInitialDataLoaded {
    return _preferences!.getBool(_initialDataLoadedKey) ?? false;
  }

  int get lastDataLoadTimestamp {
    return _preferences!.getInt(_lastDataLoadTimestampKey) ?? 0;
  }

  int get widgetRefreshInterval {
    return _preferences!.getInt(_widgetRefreshIntervalKey) ?? 5; // Default 5 minutes
  }

  // Check if data needs to be reloaded (7 days = 604800000 milliseconds)
  bool get shouldReloadData {
    if (!isInitialDataLoaded) return true;

    final lastLoad = lastDataLoadTimestamp;
    if (lastLoad == 0) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLoad = (now - lastLoad) / (1000 * 60 * 60 * 24);

    return daysSinceLoad >= 7;
  }

  List<String> getStringList(String key) {
    return _preferences!.getStringList(key) ?? [];
  }

  Map<String, dynamic> defaultCustomNotificationsData = {
    "notifications_list": [
      {
        "start_at": "04:00",
        "end_at": "11:00",
        "notification_type": "morning",
        "frequency": 0,
        "notification_data": [],
        "notification_days": [],
        "notifications_categories": []
      },
      {
        "start_at": "12:00",
        "end_at": "16:00",
        "notification_type": "afternoon",
        "frequency": 0,
        "notification_data": [],
        "notification_days": [],
        "notifications_categories": []
      },
      {
        "start_at": "17:00",
        "end_at": "20:00",
        "notification_type": "evening",
        "frequency": 0,
        "notification_data": [],
        "notification_days": [],
        "notifications_categories": []
      },
      {
        "start_at": "21:00",
        "end_at": "23:50",
        "notification_type": "midnight",
        "frequency": 0,
        "notification_data": [],
        "notification_days": [],
        "notifications_categories": []
      }
    ]
  };


}