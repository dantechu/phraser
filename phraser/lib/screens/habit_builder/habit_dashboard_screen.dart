import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/consts/colors.dart' show AppColors;
import '../../services/model/habit_model.dart';
import '../../util/colors.dart';
import '../../util/helper/route_helper.dart';
import 'view_model/habit_builder_view_model.dart';
import 'habit_setup_screen.dart';
import 'widgets/habit_card_widget.dart';
import 'widgets/streak_display_widget.dart';
import 'widgets/habit_progress_chart.dart';

class HabitDashboardScreen extends StatefulWidget {
  const HabitDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HabitDashboardScreen> createState() => _HabitDashboardScreenState();
}

class _HabitDashboardScreenState extends State<HabitDashboardScreen>
    with TickerProviderStateMixin {
  final HabitBuilderViewModel _viewModel = Get.put(HabitBuilderViewModel());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Habits',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights, color: Colors.black),
            onPressed: () => _showInsights(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () => _createNewHabit(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryColor,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All Habits'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: GetBuilder<HabitBuilderViewModel>(
        builder: (vm) => TabBarView(
          controller: _tabController,
          children: [
            _buildTodayView(vm),
            _buildAllHabitsView(vm),
            _buildStatsView(vm),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewHabit,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildTodayView(HabitBuilderViewModel vm) {
    final todayHabits = vm.activeHabits;
    final completionRate = vm.getTodaysCompletionRate();
    final completedHabits = vm.getTodaysCompletedHabits();

    if (todayHabits.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's progress summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Today\'s Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completedHabits / ${todayHabits.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Habits Completed',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                value: completionRate / 100,
                                strokeWidth: 6,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${completionRate.toInt()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Motivational message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Text(
                  _getMotivationalEmoji(completionRate),
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getMotivationalMessage(completionRate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's habits
          Text(
            'Today\'s Habits',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayHabits.length,
            itemBuilder: (context, index) {
              final habit = todayHabits[index];
              return HabitCardWidget(
                habit: habit,
                onTap: () => _showHabitDetails(habit),
                onComplete: (completedValue) =>
                    _completeHabit(habit, completedValue),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllHabitsView(HabitBuilderViewModel vm) {
    final habits = vm.activeHabits;

    if (habits.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: HabitCategory.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilterChip('All', vm.selectedCategory == null,
                      () {
                    vm.selectedCategory = null;
                    vm.update();
                  });
                }

                final category = HabitCategory.values[index - 1];
                final isSelected = vm.selectedCategory == category;

                return _buildFilterChip(
                  _getCategoryName(category),
                  isSelected,
                  () {
                    vm.selectedCategory = isSelected ? null : category;
                    vm.update();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Habits list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.habitsByCategory.length,
            itemBuilder: (context, index) {
              final habit = vm.habitsByCategory[index];
              return HabitCardWidget(
                habit: habit,
                showFullDetails: true,
                onTap: () => _showHabitDetails(habit),
                onComplete: (completedValue) =>
                    _completeHabit(habit, completedValue),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView(HabitBuilderViewModel vm) {
    final habits = vm.activeHabits;

    if (habits.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Habits',
                  habits.length.toString(),
                  Icons.track_changes,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Best Streak',
                  '12 days', // TODO: Calculate from data
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completion Rate',
                  '${vm.getTodaysCompletionRate().toInt()}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Days',
                  '28 days', // TODO: Calculate from data
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress chart
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: HabitProgressChart(habits: habits),
          ),
          const SizedBox(height: 24),

          // Individual habit streaks
          Text(
            'Habit Streaks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final stats = vm.getHabitStats(habit.habitId);

              return StreakDisplayWidget(
                habit: habit,
                stats: stats,
                onTap: () => _showHabitDetails(habit),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.track_changes,
                size: 60,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Your First Habit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Build lasting change with scientifically-backed habit templates',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _createNewHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Create Your First Habit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryColor.withOpacity(0.2),
        checkmarkColor: AppColors.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryColor : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _createNewHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitSetupScreen(),
      ),
    ).then((_) => _viewModel.update());
  }

  void _showHabitDetails(Habit habit) {
    // TODO: Implement habit details screen
    Get.snackbar(
      habit.name,
      'Habit details coming soon!',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _completeHabit(Habit habit, int completedValue) async {
    try {
      await _viewModel.markHabitCompleted(habit.habitId, completedValue);
      Get.snackbar(
        'Great job!',
        'You completed ${habit.name}! Keep the streak going! 🔥',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record progress. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showInsights() {
    // TODO: Implement insights screen
    Get.snackbar(
      'Insights',
      'Detailed insights coming soon!',
      backgroundColor: Colors.purple,
      colorText: Colors.white,
    );
  }

  String _getCategoryName(HabitCategory category) {
    switch (category) {
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.relationships:
        return 'Relationships';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.creativity:
        return 'Creativity';
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.spirituality:
        return 'Spirituality';
      default:
        return category.toString().split('.').last;
    }
  }

  String _getMotivationalEmoji(double completionRate) {
    if (completionRate >= 100) return '🏆';
    if (completionRate >= 80) return '🔥';
    if (completionRate >= 60) return '💪';
    if (completionRate >= 40) return '🌱';
    if (completionRate >= 20) return '🎯';
    return '💫';
  }

  String _getMotivationalMessage(double completionRate) {
    if (completionRate >= 100) {
      return 'Perfect day! You completed all your habits. You\'re unstoppable! 🏆';
    } else if (completionRate >= 80) {
      return 'Excellent work! You\'re on fire today. Keep this momentum going! 🔥';
    } else if (completionRate >= 60) {
      return 'Great progress! You\'re building strong habits. Stay consistent! 💪';
    } else if (completionRate >= 40) {
      return 'Good start! Every habit completed is a step forward. Keep growing! 🌱';
    } else if (completionRate >= 20) {
      return 'You\'re on the right track! Small steps lead to big changes. 🎯';
    } else {
      return 'Every journey begins with a single step. You\'ve got this! 💫';
    }
  }
}
