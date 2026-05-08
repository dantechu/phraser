import 'package:flutter/material.dart';
import '../../../services/model/habit_model.dart';
import '../../../services/model/habit_progress_model.dart';

class StreakDisplayWidget extends StatelessWidget {
  final Habit habit;
  final HabitStats stats;
  final VoidCallback onTap;

  const StreakDisplayWidget({
    Key? key,
    required this.habit,
    required this.stats,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Habit icon and color
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getHabitColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getHabitIcon(),
                    color: _getHabitColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats.motivationalMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Streak info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stats.streakEmoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.currentStreak}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStreakColor(stats.currentStreak),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      stats.currentStreak == 1 ? 'day' : 'days',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                
                // Best streak indicator
                if (stats.longestStreak > stats.currentStreak)
                  Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 16,
                      ),
                      Text(
                        '${stats.longestStreak}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getHabitColor() {
    if (habit.colorHex != null) {
      return Color(int.parse(habit.colorHex!.replaceAll('#', '0xFF')));
    }
    
    // Default colors based on category
    switch (habit.categoryEnum) {
      case HabitCategory.healthFitness:
        return Colors.orange;
      case HabitCategory.mindEmotions:
        return Colors.blue;
      case HabitCategory.learningGrowth:
        return Colors.purple;
      case HabitCategory.productivityWork:
        return Colors.green;
      case HabitCategory.financeMoney:
        return Colors.teal;
      case HabitCategory.lifestyleRoutine:
        return Colors.pink;
      case HabitCategory.relationshipsSocial:
        return Colors.red;
      case HabitCategory.creativityHobbies:
        return Colors.deepOrange;
      case HabitCategory.contributionImpact:
        return Colors.brown;
      case HabitCategory.spiritualityMindfulness:
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  IconData _getHabitIcon() {
    switch (habit.categoryEnum) {
      case HabitCategory.healthFitness:
        return Icons.fitness_center;
      case HabitCategory.mindEmotions:
        return Icons.psychology;
      case HabitCategory.learningGrowth:
        return Icons.school;
      case HabitCategory.productivityWork:
        return Icons.trending_up;
      case HabitCategory.financeMoney:
        return Icons.attach_money;
      case HabitCategory.lifestyleRoutine:
        return Icons.schedule;
      case HabitCategory.relationshipsSocial:
        return Icons.people;
      case HabitCategory.creativityHobbies:
        return Icons.palette;
      case HabitCategory.contributionImpact:
        return Icons.volunteer_activism;
      case HabitCategory.spiritualityMindfulness:
        return Icons.spa;
      default:
        return Icons.track_changes;
    }
  }

  Color _getStreakColor(int streak) {
    if (streak == 0) return Colors.grey;
    if (streak < 7) return Colors.orange;
    if (streak < 30) return Colors.blue;
    if (streak < 100) return Colors.purple;
    return Colors.red;
  }
}