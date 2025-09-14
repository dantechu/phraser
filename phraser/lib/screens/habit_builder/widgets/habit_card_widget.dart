import 'package:flutter/material.dart';
import 'package:phraser/consts/colors.dart';
import '../../../services/model/habit_model.dart';
import '../../../util/colors.dart';

class HabitCardWidget extends StatelessWidget {
  final Habit habit;
  final bool showFullDetails;
  final VoidCallback onTap;
  final Function(int) onComplete;

  const HabitCardWidget({
    Key? key,
    required this.habit,
    this.showFullDetails = false,
    required this.onTap,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final isCompletedToday = false; // TODO: Check from database
    final currentProgress = 0; // TODO: Get from database

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Habit icon and color
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getHabitColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getHabitIcon(),
                        color: _getHabitColor(),
                        size: 24,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${habit.targetValue} ${habit.unit}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _getDifficultyLabel(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: _getDifficultyColor(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Completion status
                    if (isCompletedToday)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 20,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showCompletionDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getHabitColor().withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: _getHabitColor(),
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                if (showFullDetails) ...[
                  const SizedBox(height: 16),

                  // Progress indicator
                  Row(
                    children: [
                      Text(
                        'Progress: $currentProgress / ${habit.targetValue} ${habit.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${((currentProgress / habit.targetValue) * 100).clamp(0, 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getHabitColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value:
                        (currentProgress / habit.targetValue).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getHabitColor()),
                  ),

                  if (habit.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      habit.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    final TextEditingController valueController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Complete ${habit.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How much did you complete?',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Value input
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (${habit.unit})',
                hintText: habit.targetValue.toString(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: habit.unit,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Notes input
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'How did it feel?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value =
                  int.tryParse(valueController.text) ?? habit.targetValue;
              onComplete(value);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getHabitColor(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Color _getHabitColor() {
    if (habit.colorHex != null) {
      return Color(int.parse(habit.colorHex!.replaceAll('#', '0xFF')));
    }

    // Default colors based on category
    switch (habit.categoryEnum) {
      case HabitCategory.mindfulness:
        return Colors.blue;
      case HabitCategory.fitness:
        return Colors.orange;
      case HabitCategory.productivity:
        return Colors.green;
      case HabitCategory.relationships:
        return Colors.pink;
      case HabitCategory.learning:
        return Colors.purple;
      case HabitCategory.creativity:
        return Colors.red;
      case HabitCategory.health:
        return Colors.teal;
      case HabitCategory.spirituality:
        return Colors.indigo;
      default:
        return AppColors.primaryColor;
    }
  }

  IconData _getHabitIcon() {
    switch (habit.categoryEnum) {
      case HabitCategory.mindfulness:
        return Icons.self_improvement;
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.productivity:
        return Icons.trending_up;
      case HabitCategory.relationships:
        return Icons.people;
      case HabitCategory.learning:
        return Icons.school;
      case HabitCategory.creativity:
        return Icons.palette;
      case HabitCategory.health:
        return Icons.health_and_safety;
      case HabitCategory.spirituality:
        return Icons.spa;
      default:
        return Icons.track_changes;
    }
  }

  Color _getDifficultyColor() {
    switch (habit.difficultyEnum) {
      case HabitDifficulty.beginner:
        return Colors.green;
      case HabitDifficulty.intermediate:
        return Colors.orange;
      case HabitDifficulty.advanced:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel() {
    switch (habit.difficultyEnum) {
      case HabitDifficulty.beginner:
        return 'Beginner';
      case HabitDifficulty.intermediate:
        return 'Intermediate';
      case HabitDifficulty.advanced:
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }
}
