import 'package:flutter/material.dart';
import 'package:phraser/util/status_bar_helper.dart';
import 'package:phraser/util/colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                _buildStatRow(context, 'Total Mood Entries', '127', Icons.psychology),
                const SizedBox(height: 12),
                _buildStatRow(context, 'This Week', '12', Icons.calendar_today),
                const SizedBox(height: 12),
                _buildStatRow(context, 'Current Streak', '7 days', Icons.local_fire_department),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mood Distribution
          _buildStatCard(
            context,
            title: 'Mood Distribution',
            child: Column(
              children: [
                _buildProgressBar(context, 'Happy', 0.45, Colors.green),
                const SizedBox(height: 12),
                _buildProgressBar(context, 'Calm', 0.30, Colors.blue),
                const SizedBox(height: 12),
                _buildProgressBar(context, 'Anxious', 0.15, Colors.orange),
                const SizedBox(height: 12),
                _buildProgressBar(context, 'Sad', 0.10, Colors.red),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Weekly Trend
          _buildStatCard(
            context,
            title: 'Weekly Trend',
            child: Column(
              children: [
                _buildTrendItem(context, 'Monday', 'Happy', Colors.green, '85%'),
                const SizedBox(height: 8),
                _buildTrendItem(context, 'Tuesday', 'Calm', Colors.blue, '70%'),
                const SizedBox(height: 8),
                _buildTrendItem(context, 'Wednesday', 'Happy', Colors.green, '90%'),
                const SizedBox(height: 8),
                _buildTrendItem(context, 'Thursday', 'Anxious', Colors.orange, '60%'),
                const SizedBox(height: 8),
                _buildTrendItem(context, 'Friday', 'Happy', Colors.green, '88%'),
                const SizedBox(height: 8),
                _buildTrendItem(context, 'Saturday', 'Calm', Colors.blue, '75%'),
                const SizedBox(height: 8),
                _buildTrendItem(context, 'Sunday', 'Happy', Colors.green, '92%'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Most Used Quotes
          _buildStatCard(
            context,
            title: 'Most Used Mood Quotes',
            child: Column(
              children: [
                _buildQuoteItem(context, 'Motivation', '45 times'),
                const SizedBox(height: 8),
                _buildQuoteItem(context, 'Relaxation', '32 times'),
                const SizedBox(height: 8),
                _buildQuoteItem(context, 'Confidence', '28 times'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                _buildStatRow(context, 'Active Habits', '8', Icons.track_changes),
                const SizedBox(height: 12),
                _buildStatRow(context, 'Completed Today', '6', Icons.check_circle),
                const SizedBox(height: 12),
                _buildStatRow(context, 'Longest Streak', '21 days', Icons.local_fire_department),
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
                _buildProgressBar(context, 'This Week', 0.85, Colors.green),
                const SizedBox(height: 12),
                _buildProgressBar(context, 'This Month', 0.72, Colors.blue),
                const SizedBox(height: 12),
                _buildProgressBar(context, 'All Time', 0.68, kPrimaryColor),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Top Performing Habits
          _buildStatCard(
            context,
            title: 'Top Performing Habits',
            child: Column(
              children: [
                _buildHabitItem(context, 'Morning Meditation', '95%', 18, Colors.purple),
                const SizedBox(height: 12),
                _buildHabitItem(context, 'Daily Exercise', '88%', 15, Colors.orange),
                const SizedBox(height: 12),
                _buildHabitItem(context, 'Read 30 Minutes', '82%', 12, Colors.blue),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Weekly Progress
          _buildStatCard(
            context,
            title: 'Weekly Progress',
            child: Column(
              children: [
                _buildWeeklyProgress(context, 'Mon', 0.75),
                const SizedBox(height: 8),
                _buildWeeklyProgress(context, 'Tue', 0.88),
                const SizedBox(height: 8),
                _buildWeeklyProgress(context, 'Wed', 0.63),
                const SizedBox(height: 8),
                _buildWeeklyProgress(context, 'Thu', 0.90),
                const SizedBox(height: 8),
                _buildWeeklyProgress(context, 'Fri', 0.85),
                const SizedBox(height: 8),
                _buildWeeklyProgress(context, 'Sat', 0.70),
                const SizedBox(height: 8),
                _buildWeeklyProgress(context, 'Sun', 0.95),
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
