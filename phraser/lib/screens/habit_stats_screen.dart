import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/screens/habit_builder_screen.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/preferences.dart';

class HabitStatsScreen extends StatefulWidget {
  const HabitStatsScreen({super.key});

  @override
  State<HabitStatsScreen> createState() => _HabitStatsScreenState();
}

class _HabitStatsScreenState extends State<HabitStatsScreen> {
  List<HabitData> userHabits = [];

  @override
  void initState() {
    super.initState();
    _loadUserHabits();
  }

  void _loadUserHabits() {
    final savedHabits = Preferences.instance.getStringList('user_habits');
    final allHabitTemplates = _getAllHabitTemplates();
    
    setState(() {
      userHabits = savedHabits.map((habitName) {
        final template = allHabitTemplates.firstWhere(
          (template) => template.name == habitName,
          orElse: () => _getDefaultHabitTemplate(habitName),
        );
        
        return HabitData(
          emoji: template.emoji,
          name: template.name,
          description: template.description,
          currentStreak: _getHabitStreak(habitName),
          longestStreak: _getHabitLongestStreak(habitName),
          completionRate: _getHabitCompletionRate(habitName),
          totalCompleted: _getHabitTotalCompleted(habitName),
          quotes: _getHabitQuotes(habitName),
        );
      }).toList();
    });
  }

  List<HabitTemplate> _getAllHabitTemplates() {
    return [
      HabitTemplate('💧', 'Drink Water', 'Stay hydrated throughout the day', Colors.blue.shade100),
      HabitTemplate('📖', 'Read Daily', 'Read for at least 15 minutes', Colors.orange.shade100),
      HabitTemplate('🧘', 'Meditate', 'Practice mindfulness daily', Colors.purple.shade100),
      HabitTemplate('🏃', 'Exercise', 'Stay active and healthy', Colors.green.shade100),
      HabitTemplate('📝', 'Journal', 'Write down your thoughts', Colors.yellow.shade100),
      HabitTemplate('🌅', 'Early Rise', 'Wake up early to start fresh', Colors.pink.shade100),
      HabitTemplate('🥗', 'Eat Healthy', 'Choose nutritious meals', Colors.lime.shade100),
      HabitTemplate('💤', 'Sleep Well', 'Get 7-8 hours of quality sleep', Colors.indigo.shade100),
      HabitTemplate('📱', 'Digital Detox', 'Limit screen time', Colors.red.shade100),
      HabitTemplate('🙏', 'Practice Gratitude', 'Count your daily blessings', Colors.teal.shade100),
      HabitTemplate('🎨', 'Creative Time', 'Engage in creative activities', Colors.cyan.shade100),
      HabitTemplate('🤝', 'Connect', 'Reach out to friends/family', Colors.deepOrange.shade100),
    ];
  }

  HabitTemplate _getDefaultHabitTemplate(String name) {
    return HabitTemplate('⭐', name, 'Custom habit', Colors.grey.shade100);
  }

  int _getHabitStreak(String habitName) {
    // Simulate different streaks for demo
    final random = habitName.hashCode % 20;
    return random;
  }

  int _getHabitLongestStreak(String habitName) {
    return _getHabitStreak(habitName) + (habitName.hashCode % 10);
  }

  int _getHabitCompletionRate(String habitName) {
    final random = (habitName.hashCode % 30) + 60;
    return random > 100 ? 100 : random;
  }

  int _getHabitTotalCompleted(String habitName) {
    return (habitName.hashCode % 200) + 50;
  }

  List<String> _getHabitQuotes(String habitName) {
    final habitQuotes = {
      'Drink Water': [
        'Water is life. Drink up and feel alive!',
        'Every sip of water is a step towards better health.',
        'Hydration is the foundation of vitality.',
      ],
      'Read Daily': [
        'Reading is to the mind what exercise is to the body.',
        'Books are a uniquely portable magic.',
        'The more that you read, the more you will know.',
      ],
      'Meditate': [
        'Peace comes from within. Do not seek it without.',
        'Meditation is not a way of making your mind quiet. It is finding the quiet that is already there.',
        'The present moment is the only time over which we have dominion.',
      ],
      'Exercise': [
        'Take care of your body. It\'s the only place you have to live.',
        'Every workout is progress.',
        'Strong body, strong mind.',
      ],
      'Journal': [
        'Writing is thinking on paper.',
        'Your thoughts are worth capturing.',
        'Reflection leads to growth.',
      ],
    };
    
    return habitQuotes[habitName] ?? [
      'Every day is a new opportunity to grow.',
      'Small steps lead to big changes.',
      'Consistency is key to success.',
    ];
  }

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
                        '${(userHabits.fold(0, (sum, habit) => sum + habit.completionRate) / userHabits.length).round()}%',
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