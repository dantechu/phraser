import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/util/preferences.dart';

enum ViewingMode { categories, mood, habits, aiChat }

class ViewingModeViewModel extends GetxController {
  static ViewingModeViewModel get instance => Get.find<ViewingModeViewModel>();

  // Current viewing mode
  ViewingMode _currentMode = ViewingMode.categories;
  ViewingMode get currentMode => _currentMode;

  // Current context information
  String _currentCategoryName = '';
  String _currentMoodName = '';
  String _currentHabitName = '';

  // Getters for current context
  String get currentCategoryName => _currentCategoryName;
  String get currentMoodName => _currentMoodName;
  String get currentHabitName => _currentHabitName;

  @override
  void onInit() {
    super.onInit();
    _loadSavedState();
  }

  /// Load saved viewing mode and context from preferences
  void _loadSavedState() {
    // Load saved navigation tab
    final savedTab = Preferences.instance.selectedNavigationTab;
    switch (savedTab) {
      case 'Categories':
        _currentMode = ViewingMode.categories;
        _currentCategoryName =
            Preferences.instance.savedCategoryName ?? 'Categories';
        break;
      case 'Mood':
        _currentMode = ViewingMode.mood;
        _loadCurrentMoodName();
        break;
      case 'Habits':
        _currentMode = ViewingMode.habits;
        _currentHabitName = 'Habit Building';
        break;
      case 'AI Chat':
        _currentMode = ViewingMode.aiChat;
        break;
      default:
        _currentMode = ViewingMode.categories;
        _currentCategoryName = 'Categories';
    }
    update();
  }

  /// Load current mood name from preferences
  void _loadCurrentMoodName() {
    final currentMood = Preferences.instance.currentMood;
    final isMoodFilterEnabled = Preferences.instance.isMoodFilterEnabled;

    if (currentMood != null && isMoodFilterEnabled) {
      _currentMoodName = _formatMoodName(currentMood);
    } else {
      _currentMoodName = 'Mood';
    }
  }

  /// Format mood name for display
  String _formatMoodName(String mood) {
    return mood[0].toUpperCase() + mood.substring(1);
  }

  /// Switch to Categories mode with specific category
  void switchToCategories({String? categoryName}) {
    _currentMode = ViewingMode.categories;
    if (categoryName != null && categoryName.isNotEmpty) {
      _currentCategoryName = categoryName;
      Preferences.instance.savedCategoryName = categoryName;
    } else {
      _currentCategoryName =
          Preferences.instance.savedCategoryName ?? 'Categories';
    }
    Preferences.instance.selectedNavigationTab = 'Categories';
    update();
  }

  /// Switch to Mood mode with specific mood
  void switchToMood({String? moodName}) {
    _currentMode = ViewingMode.mood;
    if (moodName != null && moodName.isNotEmpty) {
      _currentMoodName = _formatMoodName(moodName);
    } else {
      _loadCurrentMoodName();
    }
    Preferences.instance.selectedNavigationTab = 'Mood';
    update();
  }

  /// Switch to Habits mode with specific habit
  void switchToHabits({String? habitName}) {
    _currentMode = ViewingMode.habits;
    if (habitName != null && habitName.isNotEmpty) {
      _currentHabitName = habitName;
    } else {
      _currentHabitName = 'Habit Building';
    }
    Preferences.instance.selectedNavigationTab = 'Habits';
    update();
  }

  /// Switch to AI Chat mode
  void switchToAIChat() {
    _currentMode = ViewingMode.aiChat;
    Preferences.instance.selectedNavigationTab = 'AI Chat';
    update();
  }

  /// Get display text for current mode
  String getCurrentModeDisplayText() {
    switch (_currentMode) {
      case ViewingMode.categories:
        return _currentCategoryName.isNotEmpty
            ? _currentCategoryName
            : 'Categories';
      case ViewingMode.mood:
        return _currentMoodName.isNotEmpty ? _currentMoodName : 'Mood';
      case ViewingMode.habits:
        return _currentHabitName.isNotEmpty ? _currentHabitName : 'Habits';
      case ViewingMode.aiChat:
        return 'AI Chat';
    }
  }

  /// Get display text with ellipsis for long text
  String getCurrentModeDisplayTextEllipsed({int maxLength = 12}) {
    final text = getCurrentModeDisplayText();
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Get icon for current mode
  IconData getCurrentModeIcon() {
    switch (_currentMode) {
      case ViewingMode.categories:
        return Icons.category_outlined;
      case ViewingMode.mood:
        return Icons.psychology_outlined;
      case ViewingMode.habits:
        return Icons.track_changes_outlined;
      case ViewingMode.aiChat:
        return Icons.chat_outlined;
    }
  }

  /// Check if specific mode is currently active
  bool isCurrentMode(ViewingMode mode) {
    return _currentMode == mode;
  }

  /// Get navigation tab name for current mode
  String getCurrentTabName() {
    switch (_currentMode) {
      case ViewingMode.categories:
        return 'Categories';
      case ViewingMode.mood:
        return 'Mood';
      case ViewingMode.habits:
        return 'Habits';
      case ViewingMode.aiChat:
        return 'AI Chat';
    }
  }

  /// Update category name when user switches categories
  void updateCategoryName(String categoryName) {
    if (_currentMode == ViewingMode.categories && categoryName.isNotEmpty) {
      _currentCategoryName = categoryName;
      Preferences.instance.savedCategoryName = categoryName;
      update();
    }
  }

  /// Update mood name when user selects mood
  void updateMoodName(String moodName) {
    if (_currentMode == ViewingMode.mood && moodName.isNotEmpty) {
      _currentMoodName = _formatMoodName(moodName);
      update();
    }
  }

  /// Update habit name when user selects habit
  void updateHabitName(String habitName) {
    if (_currentMode == ViewingMode.habits && habitName.isNotEmpty) {
      _currentHabitName = habitName;
      update();
    }
  }

  /// Reset to default state
  void resetToDefault() {
    _currentMode = ViewingMode.categories;
    _currentCategoryName = 'Categories';
    _currentMoodName = 'Mood';
    _currentHabitName = 'Habits';
    Preferences.instance.selectedNavigationTab = 'Categories';
    update();
  }
}
