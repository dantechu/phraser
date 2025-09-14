import 'package:flutter/material.dart';
import '../../../services/model/habit_model.dart';

class HabitProgressChart extends StatelessWidget {
  final List<Habit> habits;

  const HabitProgressChart({
    Key? key,
    required this.habits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const Center(
        child: Text(
          'No habit data to display',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              'Last 7 days',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Simple progress visualization
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final dayIndex = 6 - index; // Reverse to show most recent on right
              final completionRate = _getCompletionRateForDay(dayIndex);
              final dayName = _getDayName(dayIndex);
              
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Progress bar
                    Container(
                      width: 20,
                      height: 100 * completionRate,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _getColorForCompletionRate(completionRate),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: completionRate > 0 ? [
                          BoxShadow(
                            color: _getColorForCompletionRate(completionRate).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Day label
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    // Percentage
                    Text(
                      '${(completionRate * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  double _getCompletionRateForDay(int dayIndex) {
    // Mock data - in real app, this would come from database
    final mockData = [0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.95]; // Last 7 days
    if (dayIndex < mockData.length) {
      return mockData[dayIndex];
    }
    return 0.0;
  }

  String _getDayName(int dayIndex) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: dayIndex));
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[targetDate.weekday % 7];
  }

  Color _getColorForCompletionRate(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.blue;
    if (rate >= 0.4) return Colors.orange;
    if (rate >= 0.2) return Colors.yellow;
    return Colors.grey[300]!;
  }
}