import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../services/model/habit_model.dart';
import '../../../services/model/habit_progress_model.dart';
import '../../../services/habit_quote_service.dart';
import '../../../util/Floor_db.dart';

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

  // Quote service
  final HabitQuoteService _quoteService = HabitQuoteService();

  @override
  void onInit() {
    super.onInit();
    _loadUserHabits();
    _checkDatabaseStatus(); // Check if database has quotes
  }

  /// Check database status and log information
  Future<void> _checkDatabaseStatus() async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final phrasersDAO = database.phraserDAO;
      final allQuotes = await phrasersDAO.getAllQuotesFromAllCategories();

      debugPrint('\n🔍 ═══════════════════════════════════════════════════════════');
      debugPrint('🔍 HABIT QUOTE SERVICE - DATABASE STATUS CHECK');
      debugPrint('🔍 ═══════════════════════════════════════════════════════════');
      debugPrint('📊 Total quotes in database: ${allQuotes.length}');

      if (allQuotes.isEmpty) {
        debugPrint('⚠️  WARNING: Database is EMPTY!');
        debugPrint('   No quotes found in the database.');
        debugPrint('   Please run initial data loading from the API to populate quotes.');
        debugPrint('   Navigate to the splash screen or trigger data sync.');
      } else {
        debugPrint('✅ Database has quotes loaded');

        // Get unique category IDs
        final categoryIds = allQuotes.map((q) => q.categoryId).toSet();
        debugPrint('📂 Categories in database: ${categoryIds.length}');
        debugPrint('   Category IDs: ${categoryIds.take(10).join(", ")}${categoryIds.length > 10 ? "..." : ""}');
      }

      debugPrint('🔍 ═══════════════════════════════════════════════════════════\n');
    } catch (e) {
      debugPrint('❌ Error checking database status: $e');
      debugPrint('   This might indicate the database is not initialized yet.');
    }
  }

  @override
  void dispose() {
    habitNameController.dispose();
    habitDescriptionController.dispose();
    targetValueController.dispose();
    super.dispose();
  }

  void selectCategory(HabitCategory category) async {
    selectedCategory = category;
    // Reset template selection when category changes
    selectedTemplate = null;
    isCustomHabit = false;
    update();

    // Fetch and log quote count for selected category
    await _logQuotesForCategory(category);
  }

  /// Fetch and log quotes available for a category
  Future<void> _logQuotesForCategory(HabitCategory category) async {
    try {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🎯 CATEGORY SELECTED: ${_getCategoryDisplayName(category)}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final quotes = await _quoteService.getQuotesForCategory(category);

      debugPrint('📊 Available Quotes after merge & shuffle: ${quotes.length}');

      if (quotes.isEmpty) {
        debugPrint('⚠️  WARNING: No quotes found! Database might be empty.');
        debugPrint('   Run initial data loading to populate quotes.');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ Error fetching quotes for category: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
    }
  }

  String _getCategoryDisplayName(HabitCategory category) {
    switch (category) {
      case HabitCategory.healthFitness:
        return 'Health & Fitness';
      case HabitCategory.mindEmotions:
        return 'Mind & Emotions';
      case HabitCategory.learningGrowth:
        return 'Learning & Growth';
      case HabitCategory.productivityWork:
        return 'Productivity & Work';
      case HabitCategory.financeMoney:
        return 'Finance & Money';
      case HabitCategory.lifestyleRoutine:
        return 'Lifestyle & Routine';
      case HabitCategory.relationshipsSocial:
        return 'Relationships & Social';
      case HabitCategory.creativityHobbies:
        return 'Creativity & Hobbies';
      case HabitCategory.contributionImpact:
        return 'Contribution & Impact';
      case HabitCategory.spiritualityMindfulness:
        return 'Spirituality & Mindfulness';
    }
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

    // Fetch quotes from merged categories FIRST
    final quotes = await _quoteService.getQuotesForCategory(selectedCategory!);

    // Pick a random motivational quote from merged categories
    String? motivationalQuote;
    String? tags;

    if (quotes.isNotEmpty) {
      final randomQuote = quotes[0]; // Already shuffled, so first item is random
      motivationalQuote = randomQuote.quote;

      // Store the category IDs as tags for future quote fetching
      final categoryMapping = _quoteService.getCategoryMapping();
      final categoryIds = categoryMapping[selectedCategory!] ?? [];
      tags = categoryIds.join(','); // Store as comma-separated category IDs

      debugPrint('✨ Selected quote: "$motivationalQuote"');
      debugPrint('📂 Stored category IDs for future quotes: $tags');
    } else {
      // Fallback to template quote if no quotes from database
      motivationalQuote = selectedTemplate?.motivationalQuote;
      tags = selectedTemplate?.relatedTags.join(',');
      debugPrint('⚠️  Using template quote as fallback');
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
      motivationalQuote: motivationalQuote, // NOW SET FROM MERGED QUOTES!
      tags: tags, // NOW SET AS CATEGORY IDS FOR FUTURE FETCHING!
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

    // Fetch and log quotes for this habit (for verification)
    await _logQuotesForHabit(habit);

    // Add to local list
    userHabits.add(habit);
    update();
  }

  /// Fetch and log quotes available for a specific habit
  Future<void> _logQuotesForHabit(Habit habit) async {
    try {
      debugPrint('\n═══════════════════════════════════════════════════════════');
      debugPrint('✨ HABIT CREATED: ${habit.name}');
      debugPrint('═══════════════════════════════════════════════════════════');

      final quotes = await _quoteService.getQuotesForHabit(habit);

      debugPrint('\n🎯 Habit Category: ${_getCategoryDisplayName(habit.categoryEnum)}');
      debugPrint('📊 Total Quotes Available (after merge & shuffle): ${quotes.length}');

      if (quotes.isNotEmpty) {
        debugPrint('\n📝 Sample Quotes (first 3):');
        for (int i = 0; i < (quotes.length > 3 ? 3 : quotes.length); i++) {
          debugPrint('  ${i + 1}. "${quotes[i].quote}"');
          debugPrint('     - From: ${quotes[i].categoryName} (ID: ${quotes[i].categoryId})');
        }
      } else {
        debugPrint('⚠️  WARNING: No quotes available for this habit category!');
        debugPrint('   Database might be empty. Run initial data loading.');
      }

      debugPrint('\n═══════════════════════════════════════════════════════════\n');
    } catch (e) {
      debugPrint('❌ Error fetching quotes for habit: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
    }
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

  /// Get a fresh motivational quote for a habit from its stored category IDs
  /// This can be called daily or when user wants a new quote
  Future<String?> getFreshQuoteForHabit(Habit habit) async {
    try {
      // Use the stored tags (category IDs) to fetch fresh quotes
      final quotes = await _quoteService.getQuotesForHabit(habit);

      if (quotes.isNotEmpty) {
        // Return a random quote (already shuffled)
        return quotes[0].quote;
      }

      // Fallback to stored quote if no quotes available
      return habit.motivationalQuote;
    } catch (e) {
      debugPrint('❌ Error fetching fresh quote: $e');
      return habit.motivationalQuote; // Return stored quote on error
    }
  }

  /// Get multiple fresh quotes for a habit (for carousel/list)
  Future<List<String>> getFreshQuotesForHabit(Habit habit, int count) async {
    try {
      final phrasers = await _quoteService.getRandomQuotesForHabit(habit, count);
      return phrasers.map((p) => p.quote).toList();
    } catch (e) {
      debugPrint('❌ Error fetching fresh quotes: $e');
      return habit.motivationalQuote != null ? [habit.motivationalQuote!] : [];
    }
  }
}