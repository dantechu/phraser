import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';
import '../services/model/habit_model.dart';

/// Service for managing and merging quotes for habit builder
/// Maps habit categories to phraser categories and provides shuffled quotes
class HabitQuoteService {
  static final HabitQuoteService _instance = HabitQuoteService._internal();
  factory HabitQuoteService() => _instance;
  HabitQuoteService._internal();

  /// Maps each habit category to relevant phraser category IDs
  /// Based on the mapping defined in habit_builder.md
  Map<HabitCategory, List<String>> getCategoryMapping() {
    return {
      // Health & Fitness
      HabitCategory.healthFitness: [
        '44', // Running
        '11', // Gym
        '42', // Body Positivity
        '36', // Healthier Life
      ],

      // Mind & Emotions
      HabitCategory.mindEmotions: [
        '50', // Patience
        '45', // Respect
        '43', // Kindness
        '40', // Dream
        '37', // Motivation
        '12', // Self Love
        '41', // Self Respect
        '35', // Hard Times
        '51', // Moving On
      ],

      // Learning & Growth
      HabitCategory.learningGrowth: [
        '47', // Quiet People
        '29', // Failure
        '28', // Success
        '18', // Leadership
        '13', // Personal Growth
        '38', // Wisdom
      ],

      // Productivity & Work
      HabitCategory.productivityWork: [
        '28', // Success
        '18', // Leadership
        '29', // Failure
        '37', // Motivation
      ],

      // Finance & Money
      HabitCategory.financeMoney: [
        '28', // Success
        '38', // Wisdom
      ],

      // Lifestyle & Routine
      HabitCategory.lifestyleRoutine: [
        '36', // Healthier Life
        '40', // Dream
        '50', // Patience
      ],

      // Relationships & Social
      HabitCategory.relationshipsSocial: [
        '46', // Trust
        '34', // Girlfriend
        '33', // Boyfriend
        '27', // Anniversary
        '26', // Marriage
        '24', // Romantic
        '48', // Parenting
        '32', // Mother
        '31', // Father
        '30', // Family
        '43', // Kindness
        '45', // Respect
      ],

      // Creativity & Hobbies
      HabitCategory.creativityHobbies: [
        '23', // Basketball
        '22', // Football
        '21', // Cat love
        '19', // Dog love
        '39', // Rain
        '25', // Sunshine
        '20', // Ocean
      ],

      // Contribution & Impact
      HabitCategory.contributionImpact: [
        '43', // Kindness
        '18', // Leadership
        '48', // Parenting
        '45', // Respect
      ],

      // Spirituality & Mindfulness
      HabitCategory.spiritualityMindfulness: [
        '49', // Biblical Verses
        '50', // Patience
        '40', // Dream
        '39', // Rain
        '25', // Sunshine
        '20', // Ocean
        '41', // Self Respect
        '38', // Wisdom
      ],
    };
  }

  /// Get merged and shuffled quotes for a specific habit
  /// Returns a list of phrasers from all relevant categories
  Future<List<Phraser>> getQuotesForHabit(Habit habit) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final phrasersDAO = database.phraserDAO;

      // Get category IDs for this habit
      final categoryMapping = getCategoryMapping();
      final categoryIds = categoryMapping[habit.categoryEnum] ?? [];

      if (categoryIds.isEmpty) {
        debugPrint('⚠️ No category mapping found for ${habit.categoryEnum}');
        return [];
      }

      debugPrint('📋 Fetching quotes for habit: ${habit.name}');
      debugPrint('📂 Habit Category: ${habit.categoryEnum}');
      debugPrint('🎯 Mapped Category IDs: $categoryIds');

      // Fetch quotes from all mapped categories
      List<Phraser> allQuotes = [];

      for (String categoryId in categoryIds) {
        final quotes = await phrasersDAO.getPhrasersByCategoryId(categoryId);
        if (quotes.isNotEmpty) {
          allQuotes.addAll(quotes);
          debugPrint('  ✓ Category ID $categoryId: ${quotes.length} quotes');
        } else {
          debugPrint('  ✗ Category ID $categoryId: No quotes found');
        }
      }

      // Shuffle the merged quotes
      allQuotes.shuffle(Random());

      debugPrint('🎲 Total quotes after shuffle: ${allQuotes.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return allQuotes;
    } catch (e) {
      debugPrint('❌ Error fetching quotes for habit: $e');
      return [];
    }
  }

  /// Get quotes for a habit category (without specific habit instance)
  Future<List<Phraser>> getQuotesForCategory(HabitCategory category) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final phrasersDAO = database.phraserDAO;

      final categoryMapping = getCategoryMapping();
      final categoryIds = categoryMapping[category] ?? [];

      if (categoryIds.isEmpty) {
        debugPrint('⚠️ No category mapping found for $category');
        return [];
      }

      debugPrint('📋 Fetching quotes for category: $category');
      debugPrint('🎯 Mapped Category IDs: $categoryIds');

      List<Phraser> allQuotes = [];

      for (String categoryId in categoryIds) {
        final quotes = await phrasersDAO.getPhrasersByCategoryId(categoryId);
        if (quotes.isNotEmpty) {
          allQuotes.addAll(quotes);
          debugPrint('  ✓ Category ID $categoryId: ${quotes.length} quotes');
        }
      }

      allQuotes.shuffle(Random());

      debugPrint('🎲 Total quotes after shuffle: ${allQuotes.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return allQuotes;
    } catch (e) {
      debugPrint('❌ Error fetching quotes for category: $e');
      return [];
    }
  }

  /// Get a random quote for a habit
  Future<Phraser?> getRandomQuoteForHabit(Habit habit) async {
    final quotes = await getQuotesForHabit(habit);
    if (quotes.isEmpty) return null;
    return quotes[Random().nextInt(quotes.length)];
  }

  /// Get multiple random quotes for a habit
  Future<List<Phraser>> getRandomQuotesForHabit(Habit habit, int count) async {
    final quotes = await getQuotesForHabit(habit);
    if (quotes.isEmpty) return [];

    final shuffled = List<Phraser>.from(quotes)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  /// Get quote count for a specific habit without loading all quotes
  Future<int> getQuoteCountForHabit(Habit habit) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final phrasersDAO = database.phraserDAO;

      final categoryMapping = getCategoryMapping();
      final categoryIds = categoryMapping[habit.categoryEnum] ?? [];

      int totalCount = 0;

      for (String categoryId in categoryIds) {
        final count = await phrasersDAO.getPhraserCountByCategoryId(categoryId);
        totalCount += count ?? 0;
      }

      return totalCount;
    } catch (e) {
      debugPrint('❌ Error counting quotes for habit: $e');
      return 0;
    }
  }

  /// Get statistics about available quotes for all habit categories
  Future<Map<HabitCategory, int>> getQuoteStatistics() async {
    final stats = <HabitCategory, int>{};

    for (final category in HabitCategory.values) {
      final quotes = await getQuotesForCategory(category);
      stats[category] = quotes.length;
    }

    return stats;
  }

  /// Print detailed statistics for debugging
  Future<void> printQuoteStatistics() async {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📊 HABIT QUOTE STATISTICS');
    debugPrint('═══════════════════════════════════════════════════════════');

    final stats = await getQuoteStatistics();

    for (final entry in stats.entries) {
      debugPrint('${_getCategoryName(entry.key)}: ${entry.value} quotes');
    }

    final total = stats.values.fold(0, (sum, count) => sum + count);
    debugPrint('───────────────────────────────────────────────────────────');
    debugPrint('📚 Total Quotes Available: $total');
    debugPrint('═══════════════════════════════════════════════════════════');
  }

  String _getCategoryName(HabitCategory category) {
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
}
