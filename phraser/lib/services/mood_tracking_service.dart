import 'package:phraser/services/model/mood_model.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:uuid/uuid.dart';

/// Comprehensive mood tracking service with world-standard analytics
///
/// Features:
/// - Mood entry recording with notes, triggers, and activities
/// - Streak calculation (consecutive days with mood entries)
/// - Mood distribution analysis
/// - Intensity tracking and patterns
/// - Time-based analytics (daily, weekly, monthly)
/// - Trigger identification
/// - Emotional wellness scoring
/// - Mood patterns and insights
class MoodTrackingService {
  static final MoodTrackingService _instance = MoodTrackingService._internal();
  factory MoodTrackingService() => _instance;
  MoodTrackingService._internal();

  // ==================== Core Recording Methods ====================

  /// Records a new mood entry
  Future<MoodEntry> recordMoodEntry({
    required MoodType mood,
    required MoodIntensity intensity,
    String? notes,
    List<String>? triggers,
    String? activities,
  }) async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;

    final now = DateTime.now();
    final entry = MoodEntry(
      moodId: const Uuid().v4(),
      mood: mood.toString().split('.').last,
      intensity: intensity.toString().split('.').last,
      date: _formatDate(now),
      timestamp: now.toIso8601String(),
      notes: notes,
      triggers: triggers?.join(','),
      activities: activities,
    );

    await moodTrackingDAO.insertMoodEntry(entry);
    return entry;
  }

  /// Updates an existing mood entry
  Future<void> updateMoodEntry(MoodEntry entry) async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;
    await moodTrackingDAO.updateMoodEntry(entry);
  }

  /// Deletes a mood entry
  Future<void> deleteMoodEntry(String moodId) async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;
    await moodTrackingDAO.deleteMoodEntry(moodId);
  }

  // ==================== Retrieval Methods ====================

  /// Gets all mood entries
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;
    return await moodTrackingDAO.getAllMoodEntries();
  }

  /// Gets mood entries for a specific date
  Future<List<MoodEntry>> getMoodEntriesForDate(DateTime date) async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;
    return await moodTrackingDAO.getMoodEntriesByDate(_formatDate(date));
  }

  /// Gets mood entries in a date range
  Future<List<MoodEntry>> getMoodEntriesInRange(DateTime startDate, DateTime endDate) async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;
    return await moodTrackingDAO.getMoodEntriesInDateRange(
      _formatDate(startDate),
      _formatDate(endDate),
    );
  }

  /// Gets recent mood entries (last N entries)
  Future<List<MoodEntry>> getRecentMoodEntries(int limit) async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;
    return await moodTrackingDAO.getRecentMoodEntries(limit);
  }

  /// Gets the latest mood entry
  Future<MoodEntry?> getLatestMoodEntry() async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;
    return await moodTrackingDAO.getLatestMoodEntry();
  }

  // ==================== Statistics Methods ====================

  /// Gets comprehensive mood statistics
  Future<MoodStatistics> getMoodStatistics({DateTime? startDate, DateTime? endDate}) async {
    // Get entries in range
    List<MoodEntry> entries;
    if (startDate != null && endDate != null) {
      entries = await getMoodEntriesInRange(startDate, endDate);
    } else {
      entries = await getAllMoodEntries();
    }

    if (entries.isEmpty) {
      return MoodStatistics.empty();
    }

    // Calculate total entries
    final totalEntries = entries.length;

    // Calculate mood distribution
    final moodCounts = <MoodType, int>{};
    final intensityCounts = <MoodIntensity, int>{};

    for (final entry in entries) {
      moodCounts[entry.moodEnum] = (moodCounts[entry.moodEnum] ?? 0) + 1;
      intensityCounts[entry.intensityEnum] = (intensityCounts[entry.intensityEnum] ?? 0) + 1;
    }

    // Calculate mood distribution percentages
    final moodDistribution = moodCounts.map(
      (mood, count) => MapEntry(mood, (count / totalEntries * 100)),
    );

    // Find most common mood
    final mostCommonMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Calculate average intensity (low=1, medium=2, high=3)
    final totalIntensity = entries.fold<double>(
      0,
      (sum, entry) => sum + _intensityToValue(entry.intensityEnum),
    );
    final averageIntensity = totalIntensity / totalEntries;

    // Calculate streak
    final currentStreak = await _calculateCurrentStreak();
    final longestStreak = await _calculateLongestStreak();

    // Get entries with triggers
    final entriesWithTriggers = entries.where((e) => e.triggers != null && e.triggers!.isNotEmpty).length;

    // Get entries with notes
    final entriesWithNotes = entries.where((e) => e.notes != null && e.notes!.isNotEmpty).length;

    // Calculate this week's entries
    final thisWeekStart = _getStartOfWeek(DateTime.now());
    final thisWeekEntries = entries.where((e) {
      final entryDate = DateTime.parse(e.date);
      return entryDate.isAfter(thisWeekStart.subtract(const Duration(days: 1)));
    }).length;

    // Calculate emotional wellness score (0-100)
    final wellnessScore = _calculateWellnessScore(entries);

    return MoodStatistics(
      totalEntries: totalEntries,
      moodDistribution: moodDistribution,
      mostCommonMood: mostCommonMood,
      averageIntensity: averageIntensity,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      entriesWithTriggers: entriesWithTriggers,
      entriesWithNotes: entriesWithNotes,
      thisWeekEntries: thisWeekEntries,
      wellnessScore: wellnessScore,
    );
  }

  /// Gets weekly mood trend (last 7 days)
  Future<List<DailyMoodSummary>> getWeeklyTrend() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    final summaries = <DailyMoodSummary>[];
    for (int i = 0; i < 7; i++) {
      final date = weekAgo.add(Duration(days: i));
      final entries = await getMoodEntriesForDate(date);

      if (entries.isEmpty) {
        summaries.add(DailyMoodSummary(
          date: date,
          entries: [],
          dominantMood: null,
          averageIntensity: 0,
          entryCount: 0,
        ));
      } else {
        final moodCounts = <MoodType, int>{};
        for (final entry in entries) {
          moodCounts[entry.moodEnum] = (moodCounts[entry.moodEnum] ?? 0) + 1;
        }

        final dominantMood = moodCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        final totalIntensity = entries.fold<double>(
          0,
          (sum, entry) => sum + _intensityToValue(entry.intensityEnum),
        );
        final averageIntensity = totalIntensity / entries.length;

        summaries.add(DailyMoodSummary(
          date: date,
          entries: entries,
          dominantMood: dominantMood,
          averageIntensity: averageIntensity,
          entryCount: entries.length,
        ));
      }
    }

    return summaries;
  }

  /// Gets monthly mood trend
  Future<Map<int, MoodTrendData>> getMonthlyTrend() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final entries = await getMoodEntriesInRange(monthStart, monthEnd);

    final weeklyData = <int, List<MoodEntry>>{};
    for (final entry in entries) {
      final entryDate = DateTime.parse(entry.date);
      final weekNumber = ((entryDate.day - 1) ~/ 7) + 1;
      weeklyData.putIfAbsent(weekNumber, () => []).add(entry);
    }

    return weeklyData.map((week, entries) {
      final moodCounts = <MoodType, int>{};
      for (final entry in entries) {
        moodCounts[entry.moodEnum] = (moodCounts[entry.moodEnum] ?? 0) + 1;
      }

      final mostCommon = moodCounts.isNotEmpty
          ? moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : MoodType.calm;

      final totalIntensity = entries.fold<double>(
        0,
        (sum, entry) => sum + _intensityToValue(entry.intensityEnum),
      );

      return MapEntry(
        week,
        MoodTrendData(
          entryCount: entries.length,
          mostCommonMood: mostCommon,
          averageIntensity: entries.isEmpty ? 0 : totalIntensity / entries.length,
        ),
      );
    });
  }

  /// Gets mood distribution for a specific period
  Future<Map<MoodType, MoodDistributionData>> getMoodDistribution({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<MoodEntry> entries;
    if (startDate != null && endDate != null) {
      entries = await getMoodEntriesInRange(startDate, endDate);
    } else {
      entries = await getAllMoodEntries();
    }

    if (entries.isEmpty) {
      return {};
    }

    final totalEntries = entries.length;
    final moodData = <MoodType, List<MoodEntry>>{};

    for (final entry in entries) {
      moodData.putIfAbsent(entry.moodEnum, () => []).add(entry);
    }

    return moodData.map((mood, moodEntries) {
      final count = moodEntries.length;
      final percentage = (count / totalEntries * 100);

      final intensityCounts = <MoodIntensity, int>{};
      for (final entry in moodEntries) {
        intensityCounts[entry.intensityEnum] = (intensityCounts[entry.intensityEnum] ?? 0) + 1;
      }

      final totalIntensity = moodEntries.fold<double>(
        0,
        (sum, entry) => sum + _intensityToValue(entry.intensityEnum),
      );

      return MapEntry(
        mood,
        MoodDistributionData(
          count: count,
          percentage: percentage,
          averageIntensity: totalIntensity / count,
          intensityBreakdown: intensityCounts,
        ),
      );
    });
  }

  /// Gets most common triggers
  Future<Map<String, int>> getCommonTriggers({int limit = 10}) async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;

    final entries = await moodTrackingDAO.getMoodEntriesWithTriggers();
    final triggerCounts = <String, int>{};

    for (final entry in entries) {
      if (entry.triggers != null && entry.triggers!.isNotEmpty) {
        final triggers = entry.triggers!.split(',').map((e) => e.trim()).toList();
        for (final trigger in triggers) {
          if (trigger.isNotEmpty) {
            triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
          }
        }
      }
    }

    // Sort by frequency and take top N
    final sortedTriggers = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedTriggers.take(limit));
  }

  /// Gets mood insights and patterns
  Future<MoodInsights> getMoodInsights() async {
    final entries = await getAllMoodEntries();

    if (entries.isEmpty) {
      return MoodInsights.empty();
    }

    // Calculate time-of-day patterns
    final morningMoods = <MoodType>[];
    final afternoonMoods = <MoodType>[];
    final eveningMoods = <MoodType>[];

    for (final entry in entries) {
      final hour = DateTime.parse(entry.timestamp).hour;
      if (hour < 12) {
        morningMoods.add(entry.moodEnum);
      } else if (hour < 18) {
        afternoonMoods.add(entry.moodEnum);
      } else {
        eveningMoods.add(entry.moodEnum);
      }
    }

    final mostCommonMorningMood = _findMostCommon(morningMoods);
    final mostCommonAfternoonMood = _findMostCommon(afternoonMoods);
    final mostCommonEveningMood = _findMostCommon(eveningMoods);

    // Calculate day-of-week patterns
    final dayOfWeekMoods = <int, List<MoodType>>{};
    for (final entry in entries) {
      final dayOfWeek = DateTime.parse(entry.date).weekday;
      dayOfWeekMoods.putIfAbsent(dayOfWeek, () => []).add(entry.moodEnum);
    }

    final bestDayOfWeek = dayOfWeekMoods.entries
        .map((e) => MapEntry(e.key, _calculatePositivityScore(e.value)))
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Get common triggers
    final topTriggers = await getCommonTriggers(limit: 5);

    // Calculate mood stability (lower is more stable)
    final moodStability = _calculateMoodStability(entries);

    // Get current streak
    final currentStreak = await _calculateCurrentStreak();

    return MoodInsights(
      mostCommonMorningMood: mostCommonMorningMood,
      mostCommonAfternoonMood: mostCommonAfternoonMood,
      mostCommonEveningMood: mostCommonEveningMood,
      bestDayOfWeek: _getDayName(bestDayOfWeek),
      topTriggers: topTriggers.keys.toList(),
      moodStability: moodStability,
      currentStreak: currentStreak,
    );
  }

  // ==================== Private Helper Methods ====================

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double _intensityToValue(MoodIntensity intensity) {
    switch (intensity) {
      case MoodIntensity.low:
        return 1.0;
      case MoodIntensity.medium:
        return 2.0;
      case MoodIntensity.high:
        return 3.0;
    }
  }

  /// Calculates current streak (consecutive days with mood entries)
  Future<int> _calculateCurrentStreak() async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;

    final allDates = await moodTrackingDAO.getAllDatesWithEntries();
    if (allDates.isEmpty) return 0;

    final sortedDates = allDates.map((d) => DateTime.parse(d)).toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final mostRecentDate = DateTime(sortedDates.first.year, sortedDates.first.month, sortedDates.first.day);

    // Check if most recent entry is today or yesterday
    final daysSinceLastEntry = todayDate.difference(mostRecentDate).inDays;
    if (daysSinceLastEntry > 1) return 0;

    int streak = 0;
    DateTime expectedDate = mostRecentDate;

    for (final date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (normalizedDate == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculates longest streak in history
  Future<int> _calculateLongestStreak() async {
    final database = FloorDB.instance.floorDatabase;
    final moodTrackingDAO = database.moodTrackingDAO;

    final allDates = await moodTrackingDAO.getAllDatesWithEntries();
    if (allDates.isEmpty) return 0;

    final sortedDates = allDates.map((d) => DateTime.parse(d)).toList()
      ..sort();

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prevDate = DateTime(sortedDates[i - 1].year, sortedDates[i - 1].month, sortedDates[i - 1].day);
      final currDate = DateTime(sortedDates[i].year, sortedDates[i].month, sortedDates[i].day);

      if (currDate.difference(prevDate).inDays == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  /// Calculates emotional wellness score (0-100)
  double _calculateWellnessScore(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    // Positive moods score higher
    final moodScores = {
      MoodType.happy: 95,
      MoodType.grateful: 90,
      MoodType.excited: 88,
      MoodType.confident: 85,
      MoodType.peaceful: 83,
      MoodType.calm: 80,
      MoodType.inspired: 85,
      MoodType.motivated: 82,
      MoodType.tired: 50,
      MoodType.lonely: 40,
      MoodType.frustrated: 38,
      MoodType.anxious: 35,
      MoodType.stressed: 32,
      MoodType.overwhelmed: 30,
      MoodType.sad: 25,
    };

    final totalScore = entries.fold<double>(
      0,
      (sum, entry) => sum + (moodScores[entry.moodEnum] ?? 50),
    );

    return totalScore / entries.length;
  }

  /// Calculates mood stability (0-1, lower is more stable)
  double _calculateMoodStability(List<MoodEntry> entries) {
    if (entries.length < 2) return 1.0;

    // Calculate variance in mood scores
    final moodScores = entries.map((e) => _moodToScore(e.moodEnum)).toList();
    final mean = moodScores.reduce((a, b) => a + b) / moodScores.length;
    final variance = moodScores.fold<double>(
      0,
      (sum, score) => sum + (score - mean) * (score - mean),
    ) / moodScores.length;

    // Normalize to 0-1 range
    return (variance / 100).clamp(0, 1);
  }

  double _moodToScore(MoodType mood) {
    const scores = {
      MoodType.happy: 95,
      MoodType.grateful: 90,
      MoodType.excited: 88,
      MoodType.confident: 85,
      MoodType.peaceful: 83,
      MoodType.calm: 80,
      MoodType.inspired: 85,
      MoodType.motivated: 82,
      MoodType.tired: 50,
      MoodType.lonely: 40,
      MoodType.frustrated: 38,
      MoodType.anxious: 35,
      MoodType.stressed: 32,
      MoodType.overwhelmed: 30,
      MoodType.sad: 25,
    };
    return (scores[mood] ?? 50).toDouble();
  }

  double _calculatePositivityScore(List<MoodType> moods) {
    if (moods.isEmpty) return 0;
    final totalScore = moods.fold<double>(0, (sum, mood) => sum + _moodToScore(mood));
    return totalScore / moods.length;
  }

  MoodType? _findMostCommon(List<MoodType> moods) {
    if (moods.isEmpty) return null;

    final counts = <MoodType, int>{};
    for (final mood in moods) {
      counts[mood] = (counts[mood] ?? 0) + 1;
    }

    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }
}

// ==================== Data Models ====================

class MoodStatistics {
  final int totalEntries;
  final Map<MoodType, double> moodDistribution;
  final MoodType mostCommonMood;
  final double averageIntensity;
  final int currentStreak;
  final int longestStreak;
  final int entriesWithTriggers;
  final int entriesWithNotes;
  final int thisWeekEntries;
  final double wellnessScore;

  MoodStatistics({
    required this.totalEntries,
    required this.moodDistribution,
    required this.mostCommonMood,
    required this.averageIntensity,
    required this.currentStreak,
    required this.longestStreak,
    required this.entriesWithTriggers,
    required this.entriesWithNotes,
    required this.thisWeekEntries,
    required this.wellnessScore,
  });

  factory MoodStatistics.empty() {
    return MoodStatistics(
      totalEntries: 0,
      moodDistribution: {},
      mostCommonMood: MoodType.calm,
      averageIntensity: 0,
      currentStreak: 0,
      longestStreak: 0,
      entriesWithTriggers: 0,
      entriesWithNotes: 0,
      thisWeekEntries: 0,
      wellnessScore: 0,
    );
  }
}

class DailyMoodSummary {
  final DateTime date;
  final List<MoodEntry> entries;
  final MoodType? dominantMood;
  final double averageIntensity;
  final int entryCount;

  DailyMoodSummary({
    required this.date,
    required this.entries,
    required this.dominantMood,
    required this.averageIntensity,
    required this.entryCount,
  });
}

class MoodTrendData {
  final int entryCount;
  final MoodType mostCommonMood;
  final double averageIntensity;

  MoodTrendData({
    required this.entryCount,
    required this.mostCommonMood,
    required this.averageIntensity,
  });
}

class MoodDistributionData {
  final int count;
  final double percentage;
  final double averageIntensity;
  final Map<MoodIntensity, int> intensityBreakdown;

  MoodDistributionData({
    required this.count,
    required this.percentage,
    required this.averageIntensity,
    required this.intensityBreakdown,
  });
}

class MoodInsights {
  final MoodType? mostCommonMorningMood;
  final MoodType? mostCommonAfternoonMood;
  final MoodType? mostCommonEveningMood;
  final String bestDayOfWeek;
  final List<String> topTriggers;
  final double moodStability;
  final int currentStreak;

  MoodInsights({
    required this.mostCommonMorningMood,
    required this.mostCommonAfternoonMood,
    required this.mostCommonEveningMood,
    required this.bestDayOfWeek,
    required this.topTriggers,
    required this.moodStability,
    required this.currentStreak,
  });

  factory MoodInsights.empty() {
    return MoodInsights(
      mostCommonMorningMood: null,
      mostCommonAfternoonMood: null,
      mostCommonEveningMood: null,
      bestDayOfWeek: 'N/A',
      topTriggers: [],
      moodStability: 0,
      currentStreak: 0,
    );
  }
}
