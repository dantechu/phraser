import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../services/model/habit_model.dart';
import '../../../services/model/habit_progress_model.dart';

class HabitBuilderViewModel extends GetxController {
  // Controllers for form fields
  final TextEditingController habitNameController = TextEditingController();
  final TextEditingController habitDescriptionController = TextEditingController();
  final TextEditingController targetValueController = TextEditingController();

  // Selection states
  HabitCategory? selectedCategory;
  HabitTemplate? selectedTemplate;
  bool isCustomHabit = false;
  String? selectedUnit;
  HabitFrequency? selectedFrequency;
  HabitDifficulty? selectedDifficulty;
  
  // All user habits
  List<Habit> userHabits = [];
  List<HabitProgress> habitProgresses = [];
  
  // Current habit being tracked
  Habit? currentHabit;

  @override
  void onInit() {
    super.onInit();
    _loadUserHabits();
  }

  @override
  void dispose() {
    habitNameController.dispose();
    habitDescriptionController.dispose();
    targetValueController.dispose();
    super.dispose();
  }

  void selectCategory(HabitCategory category) {
    selectedCategory = category;
    // Reset template selection when category changes
    selectedTemplate = null;
    isCustomHabit = false;
    update();
  }

  void selectTemplate(HabitTemplate template) {
    selectedTemplate = template;
    isCustomHabit = false;
    
    // Pre-fill form with template data
    habitNameController.text = template.name;
    habitDescriptionController.text = template.description;
    targetValueController.text = template.targetValue.toString();
    selectedUnit = template.unit;
    selectedFrequency = template.frequency;
    selectedDifficulty = template.difficulty;
    
    update();
  }

  void selectCustomHabit() {
    selectedTemplate = null;
    isCustomHabit = true;
    
    // Clear form for custom input
    habitNameController.clear();
    habitDescriptionController.clear();
    targetValueController.clear();
    selectedUnit = null;
    selectedFrequency = HabitFrequency.daily; // Default to daily
    selectedDifficulty = HabitDifficulty.beginner; // Default to beginner
    
    update();
  }

  void setUnit(String unit) {
    selectedUnit = unit;
    update();
  }

  void setFrequency(HabitFrequency frequency) {
    selectedFrequency = frequency;
    update();
  }

  void setDifficulty(HabitDifficulty difficulty) {
    selectedDifficulty = difficulty;
    update();
  }

  Future<void> createHabit() async {
    if (!_validateInput()) {
      throw Exception('Please fill in all required fields');
    }

    final habit = Habit(
      habitId: const Uuid().v4(),
      name: habitNameController.text.trim(),
      description: habitDescriptionController.text.trim(),
      category: selectedCategory!.toString().split('.').last,
      frequency: selectedFrequency!.toString().split('.').last,
      difficulty: selectedDifficulty!.toString().split('.').last,
      targetValue: int.parse(targetValueController.text),
      unit: selectedUnit!,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      iconPath: selectedTemplate?.iconPath,
      colorHex: selectedTemplate?.colorHex ?? '#4A90E2',
      motivationalQuote: selectedTemplate?.motivationalQuote,
      tags: selectedTemplate?.relatedTags.join(','),
    );

    // Create initial streak record
    final streak = HabitStreak(
      streakId: const Uuid().v4(),
      habitId: habit.habitId,
      currentStreak: 0,
      longestStreak: 0,
      lastCompletedDate: '',
      streakStartDate: DateTime.now().toIso8601String().split('T')[0],
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Save to database (implement database service)
    await _saveHabitToDatabase(habit, streak);
    
    // Add to local list
    userHabits.add(habit);
    update();
  }

  bool _validateInput() {
    return habitNameController.text.trim().isNotEmpty &&
           targetValueController.text.isNotEmpty &&
           int.tryParse(targetValueController.text) != null &&
           selectedUnit != null &&
           selectedFrequency != null &&
           selectedDifficulty != null &&
           selectedCategory != null;
  }

  Future<void> _saveHabitToDatabase(Habit habit, HabitStreak streak) async {
    // TODO: Implement database save
    // This would typically use Floor database or your preferred database solution
    // Example:
    // final database = FloorDB.instance.floorDatabase;
    // final habitDAO = database.habitsDAO;
    // await habitDAO.insertHabit(habit);
    // await database.habitStreaksDAO.insertStreak(streak);
    
    // For now, we'll just simulate a delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _loadUserHabits() async {
    // TODO: Implement database load
    // Load habits from database
    // userHabits = await database.habitsDAO.getAllActiveHabits();
    update();
  }

  // Methods for habit tracking and progress
  Future<void> markHabitCompleted(String habitId, int completedValue, {String? notes, String? mood}) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final progress = HabitProgress(
      progressId: const Uuid().v4(),
      habitId: habitId,
      date: today,
      completedValue: completedValue,
      isCompleted: true,
      notes: notes ?? '',
      createdAt: DateTime.now().toIso8601String(),
      mood: mood,
    );

    habitProgresses.add(progress);
    await _updateStreak(habitId);
    update();
  }

  Future<void> _updateStreak(String habitId) async {
    // TODO: Implement streak calculation logic
    // Calculate and update streak based on recent completions
  }

  List<HabitProgress> getHabitProgress(String habitId) {
    return habitProgresses.where((p) => p.habitId == habitId).toList();
  }

  HabitStats getHabitStats(String habitId) {
    final progress = getHabitProgress(habitId);
    final completions = progress.where((p) => p.isCompleted).toList();
    
    return HabitStats(
      habitId: habitId,
      totalCompletions: completions.length,
      currentStreak: _calculateCurrentStreak(progress),
      longestStreak: _calculateLongestStreak(progress),
      completionRate: _calculateCompletionRate(progress),
      totalDaysTracked: progress.length,
      averageCompletionValue: _calculateAverageCompletion(completions),
      bestPerformanceDate: _getBestPerformanceDate(completions),
      lastCompletedDate: _getLastCompletedDate(completions),
      weeklyStats: _getWeeklyStats(completions),
      monthlyTrends: _getMonthlyTrends(completions),
    );
  }

  int _calculateCurrentStreak(List<HabitProgress> progress) {
    // TODO: Implement streak calculation
    return 0;
  }

  int _calculateLongestStreak(List<HabitProgress> progress) {
    // TODO: Implement longest streak calculation
    return 0;
  }

  double _calculateCompletionRate(List<HabitProgress> progress) {
    if (progress.isEmpty) return 0.0;
    final completed = progress.where((p) => p.isCompleted).length;
    return (completed / progress.length) * 100;
  }

  double _calculateAverageCompletion(List<HabitProgress> completions) {
    if (completions.isEmpty) return 0.0;
    final total = completions.fold<int>(0, (sum, p) => sum + p.completedValue);
    return total / completions.length;
  }

  String _getBestPerformanceDate(List<HabitProgress> completions) {
    if (completions.isEmpty) return '';
    
    completions.sort((a, b) => b.completedValue.compareTo(a.completedValue));
    return completions.first.date;
  }

  String _getLastCompletedDate(List<HabitProgress> completions) {
    if (completions.isEmpty) return '';
    
    completions.sort((a, b) => b.date.compareTo(a.date));
    return completions.first.date;
  }

  Map<String, int> _getWeeklyStats(List<HabitProgress> completions) {
    final stats = <String, int>{};
    // TODO: Implement weekly statistics
    return stats;
  }

  Map<String, double> _getMonthlyTrends(List<HabitProgress> completions) {
    final trends = <String, double>{};
    // TODO: Implement monthly trends
    return trends;
  }

  // Helper methods for UI
  List<Habit> get activeHabits => userHabits.where((h) => h.isActive).toList();
  
  List<Habit> get habitsByCategory => userHabits
      .where((h) => selectedCategory == null || h.categoryEnum == selectedCategory)
      .toList();

  bool hasHabitsInCategory(HabitCategory category) {
    return userHabits.any((h) => h.categoryEnum == category && h.isActive);
  }

  int getTodaysCompletedHabits() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return habitProgresses
        .where((p) => p.date == today && p.isCompleted)
        .map((p) => p.habitId)
        .toSet()
        .length;
  }

  double getTodaysCompletionRate() {
    if (activeHabits.isEmpty) return 0.0;
    return (getTodaysCompletedHabits() / activeHabits.length) * 100;
  }
}