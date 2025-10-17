import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/model/habit_model.dart';
import '../services/model/habit_progress_model.dart';
import '../util/Floor_db.dart';

/// Comprehensive habit tracking service following best practices
/// Handles habit progress, streaks, statistics, and quote viewing progress
class HabitTrackingService {
  static final HabitTrackingService _instance = HabitTrackingService._internal();
  factory HabitTrackingService() => _instance;
  HabitTrackingService._internal();

  /// Get today's date in YYYY-MM-DD format (local timezone)
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get current timestamp in ISO 8601 format
  String _getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }

  /// Calculate days between two dates
  int _daysBetween(String date1, String date2) {
    final d1 = DateTime.parse(date1);
    final d2 = DateTime.parse(date2);
    return d2.difference(d1).inDays;
  }

  /// Mark habit as completed for today
  Future<HabitProgress> markHabitCompleted({
    required String habitId,
    required int completedValue,
    int? targetValue,
    String? notes,
    String? mood,
    int? energyLevel,
    int? difficultyRating,
  }) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final progressDAO = database.habitProgressDAO;
      final streakDAO = database.habitStreakDAO;

      final today = _getTodayDate();

      // Check if already completed today
      final existing = await progressDAO.getProgressByHabitAndDate(habitId, today);

      final isCompleted = targetValue != null ? completedValue >= targetValue : true;

      final progress = HabitProgress(
        progressId: existing?.progressId ?? const Uuid().v4(),
        habitId: habitId,
        date: today,
        completedValue: completedValue,
        isCompleted: isCompleted,
        notes: notes ?? '',
        createdAt: _getCurrentTimestamp(),
        mood: mood,
        energyLevel: energyLevel,
        difficultyRating: difficultyRating,
      );

      await progressDAO.insertProgress(progress);

      // Update streak
      await _updateStreak(habitId, today, isCompleted);

      debugPrint('✅ Habit completed: $habitId on $today (value: $completedValue, target: $targetValue)');

      return progress;
    } catch (e) {
      debugPrint('❌ Error marking habit completed: $e');
      rethrow;
    }
  }

  /// Update streak calculation
  Future<void> _updateStreak(String habitId, String date, bool isCompleted) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final streakDAO = database.habitStreakDAO;
      final progressDAO = database.habitProgressDAO;

      var streak = await streakDAO.getStreakByHabitId(habitId);

      if (streak == null) {
        // Create initial streak
        streak = HabitStreak(
          streakId: const Uuid().v4(),
          habitId: habitId,
          currentStreak: isCompleted ? 1 : 0,
          longestStreak: isCompleted ? 1 : 0,
          lastCompletedDate: isCompleted ? date : '',
          streakStartDate: isCompleted ? date : '',
          updatedAt: _getCurrentTimestamp(),
        );
        await streakDAO.insertStreak(streak);
        return;
      }

      if (!isCompleted) {
        // Don't update streak if not completed
        return;
      }

      final daysSinceLastCompletion = streak.lastCompletedDate.isNotEmpty
          ? _daysBetween(streak.lastCompletedDate, date)
          : 999;

      int newCurrentStreak;
      int newLongestStreak = streak.longestStreak;

      if (daysSinceLastCompletion == 0) {
        // Same day - no change
        newCurrentStreak = streak.currentStreak;
      } else if (daysSinceLastCompletion == 1) {
        // Consecutive day - increment streak
        newCurrentStreak = streak.currentStreak + 1;
      } else {
        // Streak broken - restart
        newCurrentStreak = 1;
      }

      // Update longest streak if current is better
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }

      await streakDAO.updateStreak(
        habitId,
        newCurrentStreak,
        newLongestStreak,
        date,
        _getCurrentTimestamp(),
      );

      debugPrint('🔥 Streak updated for $habitId: $newCurrentStreak days (longest: $newLongestStreak)');
    } catch (e) {
      debugPrint('❌ Error updating streak: $e');
    }
  }

  /// Check and reset streaks for missed days (run daily)
  Future<void> checkAndResetStreaks() async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final streakDAO = database.habitStreakDAO;

      final activeHabits = await habitsDAO.getAllActiveHabits();
      final today = _getTodayDate();

      for (final habit in activeHabits) {
        final streak = await streakDAO.getStreakByHabitId(habit.habitId);

        if (streak != null && streak.lastCompletedDate.isNotEmpty) {
          final daysSinceCompletion = _daysBetween(streak.lastCompletedDate, today);

          // If missed more than 1 day (depending on frequency), reset streak
          final maxMissedDays = _getMaxMissedDays(habit.frequencyEnum);

          if (daysSinceCompletion > maxMissedDays) {
            await streakDAO.updateStreak(
              habit.habitId,
              0, // Reset current streak
              streak.longestStreak, // Keep longest streak
              streak.lastCompletedDate,
              _getCurrentTimestamp(),
            );

            debugPrint('💔 Streak reset for ${habit.name} (missed $daysSinceCompletion days)');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking streaks: $e');
    }
  }

  int _getMaxMissedDays(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 1; // Must do it every day
      case HabitFrequency.weekly:
        return 7; // Must do it within a week
      case HabitFrequency.monthly:
        return 30; // Must do it within a month
    }
  }

  /// Get comprehensive habit statistics
  Future<HabitStats> getHabitStats(String habitId) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final progressDAO = database.habitProgressDAO;
      final streakDAO = database.habitStreakDAO;

      // Get all progress
      final allProgress = await progressDAO.getProgressByHabitId(habitId);
      final completedProgress = allProgress.where((p) => p.isCompleted).toList();

      // Get streak
      final streak = await streakDAO.getStreakByHabitId(habitId);

      // Get last 30 days for completion rate
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final thirtyDaysAgoStr = '${thirtyDaysAgo.year}-${thirtyDaysAgo.month.toString().padLeft(2, '0')}-${thirtyDaysAgo.day.toString().padLeft(2, '0')}';
      final recentProgress = await progressDAO.getRecentProgress(habitId, thirtyDaysAgoStr);
      final recentCompleted = recentProgress.where((p) => p.isCompleted).length;
      final completionRate = recentProgress.isEmpty ? 0.0 : (recentCompleted / recentProgress.length) * 100;

      // Calculate average completion value
      final avgValue = completedProgress.isEmpty
          ? 0.0
          : completedProgress.map((p) => p.completedValue).reduce((a, b) => a + b).toDouble() / completedProgress.length;

      // Best performance date
      final bestDate = completedProgress.isEmpty
          ? ''
          : completedProgress.reduce((a, b) => a.completedValue > b.completedValue ? a : b).date;

      // Weekly stats (day of week completion count)
      final weeklyStats = <String, int>{};
      for (final progress in completedProgress) {
        final date = DateTime.parse(progress.date);
        final dayName = _getDayName(date.weekday);
        weeklyStats[dayName] = (weeklyStats[dayName] ?? 0) + 1;
      }

      // Monthly trends
      final monthlyTrends = <String, double>{};
      final groupedByMonth = <String, List<HabitProgress>>{};

      for (final progress in allProgress) {
        final date = DateTime.parse(progress.date);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        groupedByMonth.putIfAbsent(monthKey, () => []).add(progress);
      }

      for (final entry in groupedByMonth.entries) {
        final completed = entry.value.where((p) => p.isCompleted).length;
        final rate = (completed / entry.value.length) * 100;
        monthlyTrends[entry.key] = rate;
      }

      return HabitStats(
        habitId: habitId,
        totalCompletions: completedProgress.length,
        currentStreak: streak?.currentStreak ?? 0,
        longestStreak: streak?.longestStreak ?? 0,
        completionRate: completionRate,
        totalDaysTracked: allProgress.length,
        averageCompletionValue: avgValue,
        bestPerformanceDate: bestDate,
        lastCompletedDate: completedProgress.isEmpty ? '' : completedProgress.first.date,
        weeklyStats: weeklyStats,
        monthlyTrends: monthlyTrends,
      );
    } catch (e) {
      debugPrint('❌ Error getting habit stats: $e');
      return HabitStats(
        habitId: habitId,
        totalCompletions: 0,
        currentStreak: 0,
        longestStreak: 0,
        completionRate: 0,
        totalDaysTracked: 0,
        averageCompletionValue: 0,
        bestPerformanceDate: '',
        lastCompletedDate: '',
        weeklyStats: {},
        monthlyTrends: {},
      );
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  /// Get today's completion status for all active habits
  Future<Map<String, bool>> getTodayCompletionStatus() async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final progressDAO = database.habitProgressDAO;

      final activeHabits = await habitsDAO.getAllActiveHabits();
      final today = _getTodayDate();
      final todayProgress = await progressDAO.getProgressByDate(today);

      final statusMap = <String, bool>{};

      for (final habit in activeHabits) {
        final progress = todayProgress.firstWhere(
          (p) => p.habitId == habit.habitId,
          orElse: () => HabitProgress(
            progressId: '',
            habitId: habit.habitId,
            date: today,
            completedValue: 0,
            isCompleted: false,
            notes: '',
            createdAt: '',
          ),
        );

        statusMap[habit.habitId] = progress.isCompleted;
      }

      return statusMap;
    } catch (e) {
      debugPrint('❌ Error getting today completion status: $e');
      return {};
    }
  }

  /// Get overall statistics for all habits
  Future<Map<String, dynamic>> getOverallStatistics() async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final progressDAO = database.habitProgressDAO;
      final streakDAO = database.habitStreakDAO;

      final activeHabits = await habitsDAO.getAllActiveHabits();
      final today = _getTodayDate();

      int totalActiveHabits = activeHabits.length;
      int todayCompleted = 0;
      int totalCompletions = 0;
      int longestCurrentStreak = 0;
      String longestStreakHabitName = '';

      for (final habit in activeHabits) {
        // Today's completion
        final todayProgress = await progressDAO.getProgressByHabitAndDate(habit.habitId, today);
        if (todayProgress?.isCompleted == true) {
          todayCompleted++;
        }

        // Total completions
        final completions = await progressDAO.getTotalCompletions(habit.habitId);
        totalCompletions += completions ?? 0;

        // Longest streak
        final streak = await streakDAO.getStreakByHabitId(habit.habitId);
        if (streak != null && streak.currentStreak > longestCurrentStreak) {
          longestCurrentStreak = streak.currentStreak;
          longestStreakHabitName = habit.name;
        }
      }

      final completionRate = totalActiveHabits > 0 ? (todayCompleted / totalActiveHabits) * 100 : 0.0;

      return {
        'total_active_habits': totalActiveHabits,
        'today_completed': todayCompleted,
        'today_completion_rate': completionRate,
        'total_completions': totalCompletions,
        'longest_current_streak': longestCurrentStreak,
        'longest_streak_habit_name': longestStreakHabitName,
      };
    } catch (e) {
      debugPrint('❌ Error getting overall statistics: $e');
      return {
        'total_active_habits': 0,
        'today_completed': 0,
        'today_completion_rate': 0.0,
        'total_completions': 0,
        'longest_current_streak': 0,
        'longest_streak_habit_name': '',
      };
    }
  }

  /// Delete habit and all associated data
  Future<void> deleteHabit(String habitId) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final progressDAO = database.habitProgressDAO;
      final streakDAO = database.habitStreakDAO;

      await habitsDAO.deleteHabit(habitId);
      await progressDAO.deleteProgressByHabitId(habitId);
      await streakDAO.deleteStreakByHabitId(habitId);

      debugPrint('🗑️ Deleted habit: $habitId and all associated data');
    } catch (e) {
      debugPrint('❌ Error deleting habit: $e');
    }
  }

  /// Reset all habits and data
  Future<void> resetAllHabits() async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final progressDAO = database.habitProgressDAO;
      final streakDAO = database.habitStreakDAO;

      await habitsDAO.deactivateAllHabits(_getCurrentTimestamp());
      await progressDAO.deleteAllProgress();
      await streakDAO.deleteAllStreaks();

      debugPrint('🔄 Reset all habits and data');
    } catch (e) {
      debugPrint('❌ Error resetting habits: $e');
    }
  }
}
