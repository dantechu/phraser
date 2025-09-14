import 'package:floor/floor.dart';

import '../../util/constant_strings.dart';

@Entity(tableName: ConstantStrings.kHabitProgressTableName)
class HabitProgress {
  HabitProgress({
    required this.progressId,
    required this.habitId,
    required this.date,
    required this.completedValue,
    required this.isCompleted,
    required this.notes,
    required this.createdAt,
    this.mood,
    this.energyLevel,
    this.difficultyRating,
  });

  @primaryKey
  late final String progressId;
  late final String habitId; // Foreign key to Habit
  late final String date; // Format: YYYY-MM-DD
  late final int completedValue; // How much was completed (e.g., 8 out of 10 pushups)
  late final bool isCompleted; // Whether the target was met
  late final String notes;
  late final String createdAt;
  late final String? mood; // User's mood when completing the habit
  late final int? energyLevel; // 1-10 energy level
  late final int? difficultyRating; // 1-5 how difficult it felt

  HabitProgress.fromJson(Map<String, dynamic> json) {
    progressId = json['progress_id'];
    habitId = json['habit_id'];
    date = json['date'];
    completedValue = json['completed_value'];
    isCompleted = json['is_completed'];
    notes = json['notes'];
    createdAt = json['created_at'];
    mood = json['mood'];
    energyLevel = json['energy_level'];
    difficultyRating = json['difficulty_rating'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['progress_id'] = progressId;
    data['habit_id'] = habitId;
    data['date'] = date;
    data['completed_value'] = completedValue;
    data['is_completed'] = isCompleted;
    data['notes'] = notes;
    data['created_at'] = createdAt;
    data['mood'] = mood;
    data['energy_level'] = energyLevel;
    data['difficulty_rating'] = difficultyRating;
    return data;
  }
}

@Entity(tableName: ConstantStrings.kHabitStreakTableName)
class HabitStreak {
  HabitStreak({
    required this.streakId,
    required this.habitId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCompletedDate,
    required this.streakStartDate,
    required this.updatedAt,
  });

  @primaryKey
  late final String streakId;
  late final String habitId; // Foreign key to Habit
  late final int currentStreak; // Current consecutive days
  late final int longestStreak; // Best streak ever achieved
  late final String lastCompletedDate; // Format: YYYY-MM-DD
  late final String streakStartDate; // When current streak started
  late final String updatedAt;

  HabitStreak.fromJson(Map<String, dynamic> json) {
    streakId = json['streak_id'];
    habitId = json['habit_id'];
    currentStreak = json['current_streak'];
    longestStreak = json['longest_streak'];
    lastCompletedDate = json['last_completed_date'];
    streakStartDate = json['streak_start_date'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['streak_id'] = streakId;
    data['habit_id'] = habitId;
    data['current_streak'] = currentStreak;
    data['longest_streak'] = longestStreak;
    data['last_completed_date'] = lastCompletedDate;
    data['streak_start_date'] = streakStartDate;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class HabitStats {
  final String habitId;
  final int totalCompletions;
  final int currentStreak;
  final int longestStreak;
  final double completionRate; // Percentage over last 30 days
  final int totalDaysTracked;
  final double averageCompletionValue;
  final String bestPerformanceDate;
  final String lastCompletedDate;
  final Map<String, int> weeklyStats; // Day of week -> completion count
  final Map<String, double> monthlyTrends; // Month -> completion rate

  HabitStats({
    required this.habitId,
    required this.totalCompletions,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.totalDaysTracked,
    required this.averageCompletionValue,
    required this.bestPerformanceDate,
    required this.lastCompletedDate,
    required this.weeklyStats,
    required this.monthlyTrends,
  });

  bool get isOnStreak => currentStreak > 0;
  
  String get streakEmoji {
    if (currentStreak == 0) return "🎯";
    if (currentStreak < 7) return "🔥";
    if (currentStreak < 30) return "⚡";
    if (currentStreak < 100) return "💎";
    return "🏆";
  }

  String get motivationalMessage {
    if (currentStreak == 0) {
      return "Ready to start a new streak? You've got this! 💪";
    } else if (currentStreak == 1) {
      return "Great start! One day at a time builds lasting change. 🌱";
    } else if (currentStreak < 7) {
      return "You're building momentum! Keep the streak alive! 🔥";
    } else if (currentStreak < 30) {
      return "Amazing consistency! You're forming a strong habit! ⚡";
    } else if (currentStreak < 100) {
      return "Incredible dedication! You're a habit master! 💎";
    } else {
      return "Legendary consistency! You're an inspiration! 🏆";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'total_completions': totalCompletions,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'completion_rate': completionRate,
      'total_days_tracked': totalDaysTracked,
      'average_completion_value': averageCompletionValue,
      'best_performance_date': bestPerformanceDate,
      'last_completed_date': lastCompletedDate,
      'weekly_stats': weeklyStats,
      'monthly_trends': monthlyTrends,
    };
  }
}