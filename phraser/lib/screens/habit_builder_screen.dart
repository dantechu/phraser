import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/util/colors.dart';

class HabitBuilderScreen extends StatefulWidget {
  const HabitBuilderScreen({super.key});

  @override
  State<HabitBuilderScreen> createState() => _HabitBuilderScreenState();
}

class _HabitBuilderScreenState extends State<HabitBuilderScreen> {
  List<HabitTemplate> habitTemplates = [
    HabitTemplate('💧', 'Drink Water', 'Stay hydrated throughout the day',
        Colors.blue.shade100),
    HabitTemplate('📖', 'Read Daily', 'Read for at least 15 minutes',
        Colors.orange.shade100),
    HabitTemplate(
        '🧘', 'Meditate', 'Practice mindfulness daily', Colors.purple.shade100),
    HabitTemplate(
        '🏃', 'Exercise', 'Stay active and healthy', Colors.green.shade100),
    HabitTemplate(
        '📝', 'Journal', 'Write down your thoughts', Colors.yellow.shade100),
    HabitTemplate('🌅', 'Early Rise', 'Wake up early to start fresh',
        Colors.pink.shade100),
    HabitTemplate(
        '🥗', 'Eat Healthy', 'Choose nutritious meals', Colors.lime.shade100),
    HabitTemplate('💤', 'Sleep Well', 'Get 7-8 hours of quality sleep',
        Colors.indigo.shade100),
    HabitTemplate(
        '📱', 'Digital Detox', 'Limit screen time', Colors.red.shade100),
    HabitTemplate('🙏', 'Practice Gratitude', 'Count your daily blessings',
        Colors.teal.shade100),
    HabitTemplate('🎨', 'Creative Time', 'Engage in creative activities',
        Colors.cyan.shade100),
    HabitTemplate('🤝', 'Connect', 'Reach out to friends/family',
        Colors.deepOrange.shade100),
  ];

  Set<String> selectedHabits = {};
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Habit Builder',
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
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardColor : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (currentStep + 1) / 2,
                        backgroundColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Step ${currentStep + 1} of 2',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (currentStep == 1)
                  Text(
                    'Review & Confirm',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                if (currentStep == 1) const SizedBox(height: 4),
                Text(
                  currentStep == 0
                      ? 'Select habits you want to build. Start with 2-3 for best results.'
                      : 'Review your selected habits and start your journey!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child:
                currentStep == 0 ? _buildHabitSelection(isDark) : _buildReviewStep(isDark),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: TextButton(
                      onPressed: _previousStep,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: currentStep == 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: selectedHabits.isNotEmpty ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      currentStep == 0 ? 'Continue' : 'Start My Habits',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitSelection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: habitTemplates.length,
        itemBuilder: (context, index) {
          final habit = habitTemplates[index];
          final isSelected = selectedHabits.contains(habit.name);

          return GestureDetector(
            onTap: () => _toggleHabit(habit.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? kPrimaryColor.withOpacity(0.15)
                    : (isDark ? Theme.of(context).cardColor : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? kPrimaryColor
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? kPrimaryColor.withOpacity(0.2)
                        : (isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05)),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    Text(
                      habit.emoji,
                      style: TextStyle(
                        fontSize: isSelected ? 24 : 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? kPrimaryColor
                              : Theme.of(context).primaryColorDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        habit.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewStep(bool isDark) {
    final selectedHabitsList = habitTemplates
        .where((habit) => selectedHabits.contains(habit.name))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDark ? Colors.black : Colors.black).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Selected Habits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...selectedHabitsList.map((habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: habit.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(habit.emoji,
                                style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                Text(
                                  habit.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.1),
                  kPrimaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kPrimaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  color: kPrimaryColor,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tips for Success',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Start small - even 5 minutes counts\n• Be consistent rather than perfect\n• Track your progress daily\n• Celebrate small wins',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleHabit(String habitName) {
    setState(() {
      if (selectedHabits.contains(habitName)) {
        selectedHabits.remove(habitName);
      } else {
        selectedHabits.add(habitName);
      }
    });
  }

  void _nextStep() {
    if (currentStep == 0) {
      setState(() {
        currentStep = 1;
      });
    } else {
      _startHabits();
    }
  }

  void _previousStep() {
    setState(() {
      currentStep = 0;
    });
  }

  void _startHabits() {
    // Save habits (simplified - in real app would save to database)

    Get.snackbar(
      'Habits Created!',
      'Your ${selectedHabits.length} habits have been set up. Start building your routine!',
      backgroundColor: kPrimaryColor.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );

    // Navigate back to home
    Navigator.pop(context);
  }
}

class HabitTemplate {
  final String emoji;
  final String name;
  final String description;
  final Color color;

  HabitTemplate(this.emoji, this.name, this.description, this.color);
}
