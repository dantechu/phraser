import 'package:flutter/material.dart';
import 'package:phraser/util/status_bar_helper.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/services/mood_tracking_service.dart';
import 'package:phraser/services/habit_tracking_service.dart';
import 'package:phraser/services/model/mood_model.dart';
import 'package:phraser/util/Floor_db.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoadingMoods = true;
  bool isLoadingHabits = true;

  // Mood statistics
  MoodStatistics? moodStats;
  List<DailyMoodSummary> weeklyTrend = [];
  Map<MoodType, MoodDistributionData> moodDistribution = {};

  // Habit statistics
  int activeHabitsCount = 0;
  int completedTodayCount = 0;
  int longestHabitStreak = 0;
  double weeklyCompletionRate = 0;
  double monthlyCompletionRate = 0;
  double allTimeCompletionRate = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMoodStatistics();
    _loadHabitStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodStatistics() async {
    setState(() {
      isLoadingMoods = true;
    });

    try {
      final moodService = MoodTrackingService();

      // Get overall statistics
      final stats = await moodService.getMoodStatistics();

      // Get weekly trend
      final trend = await moodService.getWeeklyTrend();

      // Get mood distribution
      final distribution = await moodService.getMoodDistribution();

      setState(() {
        moodStats = stats;
        weeklyTrend = trend;
        moodDistribution = distribution;
        isLoadingMoods = false;
      });
    } catch (e) {
      debugPrint('Error loading mood statistics: $e');
      setState(() {
        isLoadingMoods = false;
      });
    }
  }

  Future<void> _loadHabitStatistics() async {
    setState(() {
      isLoadingHabits = true;
    });

    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final habitService = HabitTrackingService();

      // Get active habits count
      final count = await habitsDAO.getActiveHabitsCount();
      activeHabitsCount = count ?? 0;

      // Get overall statistics
      final overallStats = await habitService.getOverallStatistics();

      // Get habits and calculate longest streak
      final activeHabits = await habitsDAO.getAllActiveHabits();
      int maxStreak = 0;
      for (final habit in activeHabits) {
        final stats = await habitService.getHabitStats(habit.habitId);
        if (stats.longestStreak > maxStreak) {
          maxStreak = stats.longestStreak;
        }
      }

      setState(() {
        completedTodayCount = overallStats['completedToday'] ?? 0;
        longestHabitStreak = maxStreak;
        weeklyCompletionRate = (overallStats['weeklyCompletionRate'] ?? 0).toDouble();
        monthlyCompletionRate = (overallStats['monthlyCompletionRate'] ?? 0).toDouble();
        allTimeCompletionRate = (overallStats['allTimeCompletionRate'] ?? 0).toDouble();
        isLoadingHabits = false;
      });
    } catch (e) {
      debugPrint('Error loading habit statistics: $e');
      setState(() {
        isLoadingHabits = false;
      });
    }
  }

  String _getMoodEmoji(MoodType mood) {
    final mapping = MoodQuoteMapping.getMappingForMood(mood);
    return mapping?.emoji ?? '😊';
  }

  String _formatMoodName(MoodType mood) {
    final name = mood.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.green;
      case MoodType.sad:
        return Colors.blue;
      case MoodType.anxious:
        return Colors.orange;
      case MoodType.calm:
        return Colors.teal;
      case MoodType.motivated:
        return Colors.deepOrange;
      case MoodType.stressed:
        return Colors.red;
      case MoodType.confident:
        return Colors.purple;
      case MoodType.grateful:
        return Colors.amber;
      default:
        return kPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StatusBarHelper.standardSafeArea(
      context: context,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: kPrimaryColor,
                unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Moods'),
                  Tab(text: 'Habits'),
                ],
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMoodsTab(context),
                  _buildHabitsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodsTab(BuildContext context) {
    if (isLoadingMoods) {
      return const Center(child: CircularProgressIndicator());
    }

    if (moodStats == null || moodStats!.totalEntries == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No mood data yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your moods to see statistics',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Get top 4 moods for distribution
    final sortedMoods = moodDistribution.entries.toList()
      ..sort((a, b) => b.value.percentage.compareTo(a.value.percentage));
    final topMoods = sortedMoods.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Card
          _buildStatCard(
            context,
            title: 'Mood Overview',
            child: Column(
              children: [
                _buildStatRow(
                  context,
                  'Total Mood Entries',
                  '${moodStats!.totalEntries}',
                  Icons.psychology,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'This Week',
                  '${moodStats!.thisWeekEntries}',
                  Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'Current Streak',
                  '${moodStats!.currentStreak} days',
                  Icons.local_fire_department,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'Wellness Score',
                  '${moodStats!.wellnessScore.toInt()}/100',
                  Icons.favorite,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mood Distribution
          _buildStatCard(
            context,
            title: 'Mood Distribution',
            child: Column(
              children: topMoods.asMap().entries.map((entry) {
                final index = entry.key;
                final moodEntry = entry.value;
                final mood = moodEntry.key;
                final data = moodEntry.value;
                final color = _getMoodColor(mood);

                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 12),
                    _buildProgressBar(
                      context,
                      _formatMoodName(mood),
                      data.percentage / 100,
                      color,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Weekly Trend
          _buildStatCard(
            context,
            title: 'Weekly Trend',
            child: Column(
              children: weeklyTrend.asMap().entries.map((entry) {
                final index = entry.key;
                final summary = entry.value;
                final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final dayName = dayNames[summary.date.weekday - 1];

                final moodName = summary.dominantMood != null
                    ? _formatMoodName(summary.dominantMood!)
                    : 'No data';
                final color = summary.dominantMood != null
                    ? _getMoodColor(summary.dominantMood!)
                    : Colors.grey;
                final score = summary.entryCount > 0
                    ? '${(summary.averageIntensity * 33).toInt()}%'
                    : '-';

                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 8),
                    _buildTrendItem(context, dayName, moodName, color, score),
                  ],
                );
              }).toList(),
            ),
          ),

          if (moodStats!.entriesWithNotes > 0) ...[
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              title: 'Insights',
              child: Column(
                children: [
                  _buildQuoteItem(
                    context,
                    'Entries with notes',
                    '${moodStats!.entriesWithNotes}',
                  ),
                  if (moodStats!.entriesWithTriggers > 0) ...[
                    const SizedBox(height: 8),
                    _buildQuoteItem(
                      context,
                      'Entries with triggers',
                      '${moodStats!.entriesWithTriggers}',
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildQuoteItem(
                    context,
                    'Longest streak',
                    '${moodStats!.longestStreak} days',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitsTab(BuildContext context) {
    if (isLoadingHabits) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeHabitsCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No habit data yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building habits to see statistics',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Card
          _buildStatCard(
            context,
            title: 'Habit Overview',
            child: Column(
              children: [
                _buildStatRow(
                  context,
                  'Active Habits',
                  '$activeHabitsCount',
                  Icons.track_changes,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'Completed Today',
                  '$completedTodayCount',
                  Icons.check_circle,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'Longest Streak',
                  '$longestHabitStreak days',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Completion Rate
          _buildStatCard(
            context,
            title: 'Completion Rate',
            child: Column(
              children: [
                _buildProgressBar(
                  context,
                  'This Week',
                  weeklyCompletionRate / 100,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildProgressBar(
                  context,
                  'This Month',
                  monthlyCompletionRate / 100,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildProgressBar(
                  context,
                  'All Time',
                  allTimeCompletionRate / 100,
                  kPrimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: kPrimaryColor),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, double progress, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(BuildContext context, String day, String mood, Color color, String score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              mood,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            score,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteItem(BuildContext context, String category, String count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitItem(BuildContext context, String name, String completion, int streak, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            completion,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context, String day, double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = progress >= 0.8 ? Colors.green : progress >= 0.6 ? Colors.orange : Colors.red;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 45,
          child: Text(
            '${(progress * 100).toInt()}%',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
