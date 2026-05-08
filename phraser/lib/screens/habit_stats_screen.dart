import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/services/habit_tracking_service.dart';

class HabitStatsScreen extends StatefulWidget {
  const HabitStatsScreen({super.key});

  @override
  State<HabitStatsScreen> createState() => _HabitStatsScreenState();
}

class _HabitStatsScreenState extends State<HabitStatsScreen> {
  List<HabitData> userHabits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserHabits();
  }

  Future<void> _loadUserHabits() async {
    setState(() {
      isLoading = true;
    });

    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final trackingService = HabitTrackingService();

      // Get all active habits from database
      final activeHabits = await habitsDAO.getAllActiveHabits();

      final habitDataList = <HabitData>[];
      for (final habit in activeHabits) {
        // Get real statistics from tracking service
        final stats = await trackingService.getHabitStats(habit.habitId);

        habitDataList.add(HabitData(
          emoji: _getEmojiForCategory(habit.category),
          name: habit.name,
          description: habit.description,
          currentStreak: stats.currentStreak,
          longestStreak: stats.longestStreak,
          completionRate: stats.completionRate.toInt(),
          totalCompleted: stats.totalCompletions,
          quotes: [], // Can be populated if needed
        ));
      }

      setState(() {
        userHabits = habitDataList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading habits: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getEmojiForCategory(String category) {
    switch (category) {
      case 'healthFitness':
        return '🏃';
      case 'mindEmotions':
        return '🧠';
      case 'learningGrowth':
        return '📚';
      case 'productivityWork':
        return '💼';
      case 'financeMoney':
        return '💰';
      case 'lifestyleRoutine':
        return '🌅';
      case 'relationshipsSocial':
        return '🤝';
      case 'creativityHobbies':
        return '🎨';
      case 'contributionImpact':
        return '🤲';
      case 'spiritualityMindfulness':
        return '🧘';
      default:
        return '⭐';
    }
  }

  // Old dummy data methods removed - now using real database data from HabitTrackingService

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Habit Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section with Overall Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardColor : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${userHabits.length} Active Habits',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Streak',
                        '${userHabits.fold(0, (sum, habit) => sum + habit.currentStreak)}',
                        Icons.local_fire_department,
                        Colors.orange,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Avg. Completion',
                        userHabits.isEmpty ? '0%' : '${(userHabits.fold(0, (sum, habit) => sum + habit.completionRate) / userHabits.length).round()}%',
                        Icons.trending_up,
                        Colors.green,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Habits List
          Expanded(
            child: userHabits.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: userHabits.length,
                    itemBuilder: (context, index) {
                      final habit = userHabits[index];
                      return _buildHabitCard(habit, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColorDark.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(HabitData habit, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  habit.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    Text(
                      habit.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                ),
                onSelected: (value) => _handleMenuAction(value, habit),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('Reset Habit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Habit', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Stats
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  'Current Streak',
                  '${habit.currentStreak}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildProgressStat(
                  'Longest Streak',
                  '${habit.longestStreak}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
              Expanded(
                child: _buildProgressStat(
                  'Completion',
                  '${habit.completionRate}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  Text(
                    '${habit.completionRate}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: habit.completionRate / 100,
                backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                minHeight: 6,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Motivational Quote
          if (habit.quotes.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kPrimaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: kPrimaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Motivation',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    habit.quotes[DateTime.now().day % habit.quotes.length],
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).primaryColorDark.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).primaryColorDark.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 80,
              color: Theme.of(context).primaryColorDark.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Habits Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building healthy habits from the bottom navigation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColorDark.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create First Habit'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, HabitData habit) {
    switch (action) {
      case 'reset':
        _showResetDialog(habit);
        break;
      case 'delete':
        _showDeleteDialog(habit);
        break;
    }
  }

  void _showResetDialog(HabitData habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset ${habit.name}?'),
        content: const Text(
          'This will reset all progress including streaks and completion history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetHabit(habit);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(HabitData habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${habit.name}?'),
        content: const Text(
          'This will permanently delete this habit and all its data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHabit(habit);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _resetHabit(HabitData habit) {
    setState(() {
      habit.currentStreak = 0;
      habit.completionRate = 0;
      habit.totalCompleted = 0;
      // Keep longestStreak as historical data
    });

    Get.snackbar(
      'Habit Reset',
      '${habit.name} has been reset successfully',
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _deleteHabit(HabitData habit) {
    setState(() {
      userHabits.remove(habit);
    });

    Get.snackbar(
      'Habit Deleted',
      '${habit.name} has been deleted permanently',
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}

class HabitData {
  final String emoji;
  final String name;
  final String description;
  int currentStreak;
  final int longestStreak;
  int completionRate;
  int totalCompleted;
  final List<String> quotes;

  HabitData({
    required this.emoji,
    required this.name,
    required this.description,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.totalCompleted,
    required this.quotes,
  });
}