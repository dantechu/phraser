import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/preferences.dart' show Preferences;
import 'package:phraser/services/model/habit_model.dart';
import 'package:phraser/services/model/habit_progress_model.dart';
import 'package:phraser/services/habit_quote_service.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:uuid/uuid.dart';
import 'package:phraser/helper/navigation_helper.dart';
import 'package:phraser/screens/in_app_purchase/preimum_app_screen.dart';

class CategoryTemplate {
  final HabitCategory category;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Color iconColor;

  CategoryTemplate({
    required this.category,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}

class HabitBuilderScreen extends StatefulWidget {
  const HabitBuilderScreen({super.key});

  @override
  State<HabitBuilderScreen> createState() => _HabitBuilderScreenState();
}

class _HabitBuilderScreenState extends State<HabitBuilderScreen> {
  List<CategoryTemplate> habitCategories = [
    CategoryTemplate(
      category: HabitCategory.healthFitness,
      name: 'Health & Fitness',
      description: 'Physical wellness and exercise',
      icon: Icons.fitness_center,
      color: Colors.orange.shade100,
      iconColor: Colors.orange.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.mindEmotions,
      name: 'Mind & Emotions',
      description: 'Mental wellness and emotional health',
      icon: Icons.psychology,
      color: Colors.blue.shade100,
      iconColor: Colors.blue.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.learningGrowth,
      name: 'Learning & Growth',
      description: 'Education and personal development',
      icon: Icons.school,
      color: Colors.purple.shade100,
      iconColor: Colors.purple.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.productivityWork,
      name: 'Productivity & Work',
      description: 'Efficiency and professional development',
      icon: Icons.trending_up,
      color: Colors.green.shade100,
      iconColor: Colors.green.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.financeMoney,
      name: 'Finance & Money',
      description: 'Financial wellness and management',
      icon: Icons.attach_money,
      color: Colors.teal.shade100,
      iconColor: Colors.teal.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.lifestyleRoutine,
      name: 'Lifestyle & Routine',
      description: 'Daily routines and lifestyle choices',
      icon: Icons.schedule,
      color: Colors.pink.shade100,
      iconColor: Colors.pink.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.relationshipsSocial,
      name: 'Relationships & Social',
      description: 'Social connections and relationships',
      icon: Icons.people,
      color: Colors.red.shade100,
      iconColor: Colors.red.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.creativityHobbies,
      name: 'Creativity & Hobbies',
      description: 'Creative expression and hobbies',
      icon: Icons.palette,
      color: Colors.deepOrange.shade100,
      iconColor: Colors.deepOrange.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.contributionImpact,
      name: 'Contribution & Impact',
      description: 'Making a positive difference',
      icon: Icons.volunteer_activism,
      color: Colors.brown.shade100,
      iconColor: Colors.brown.shade700,
    ),
    CategoryTemplate(
      category: HabitCategory.spiritualityMindfulness,
      name: 'Spirituality & Mindfulness',
      description: 'Spiritual practices and mindfulness',
      icon: Icons.spa,
      color: Colors.indigo.shade100,
      iconColor: Colors.indigo.shade700,
    ),
  ];

  Set<HabitCategory> selectedCategories = {};
  int currentStep = 0;
  final HabitQuoteService _quoteService = HabitQuoteService();
  List<Phraser> mergedQuotes = []; // Store merged and shuffled quotes
  bool hasExistingHabits = false;
  List<String> existingCategories = [];
  List<String> existingHabits = [];

  @override
  void initState() {
    super.initState();
    _checkExistingHabits();
  }

  void _checkExistingHabits() {
    existingCategories = Preferences.instance.getStringList('user_categories');
    existingHabits = Preferences.instance.getStringList('user_habits');
    hasExistingHabits = existingCategories.isNotEmpty || existingHabits.isNotEmpty;

    // Pre-select existing categories
    if (existingCategories.isNotEmpty) {
      for (var categoryStr in existingCategories) {
        try {
          final category = HabitCategory.values.firstWhere(
            (c) => c.toString().split('.').last == categoryStr,
          );
          selectedCategories.add(category);
        } catch (e) {
          debugPrint('Error loading existing category: $categoryStr');
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _updateCategoryColorsForTheme(isDark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Habit Builder',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator - Only show on step 1 (Review)
          if (currentStep == 1)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
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
                          value: 1.0, // Full on step 2
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
                        'Step 2 of 2',
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
                  Text(
                    'Review & Confirm',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your selected categories and start your journey!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: currentStep == 1 ? 8 : 20),

          // Content
          Expanded(
            child:
                currentStep == 0 ? _buildHabitSelection(isDark) : _buildReviewStep(isDark),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16.0),
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
                          side: BorderSide(
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: currentStep == 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: selectedCategories.isNotEmpty ? _nextStep : null,
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
                      currentStep == 0 ? 'Continue' : 'Start Building Habits',
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
    final isPremium = Preferences.instance.isPremiumApp;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: habitCategories.length,
        itemBuilder: (context, index) {
          final category = habitCategories[index];
          final isSelected = selectedCategories.contains(category.category);
          final isLocked = !isPremium && index >= 2; // Lock after first 2 for free users

          return GestureDetector(
            onTap: () => isLocked ? _showPremiumDialog() : _toggleCategory(category.category),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kPrimaryColor.withOpacity(0.15)
                        : (isDark ? Colors.grey[850] : Colors.white),
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
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (isSelected && !isLocked)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          category.icon,
                          size: 42,
                          color: isSelected
                              ? kPrimaryColor
                              : category.iconColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? kPrimaryColor
                                : Theme.of(context).primaryColorDark,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.description,
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
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                // Lock icon overlay
                if (isLocked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewStep(bool isDark) {
    final selectedCategoriesList = habitCategories
        .where((category) => selectedCategories.contains(category.category))
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
              color: isDark ? Colors.grey[850] : Colors.white,
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
                  'Your Selected Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...selectedCategoriesList.map((category) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(category.icon,
                                size: 24, color: category.iconColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                Text(
                                  category.description,
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

  void _toggleCategory(HabitCategory category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void _nextStep() {
    if (currentStep == 0) {
      setState(() {
        currentStep = 1;
      });
    } else {
      // Check if user has existing habits before starting new ones
      if (hasExistingHabits) {
        _showReplaceHabitsDialog();
      } else {
        _startHabits();
      }
    }
  }

  void _showReplaceHabitsDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Replace Existing Habits?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You already have active habits in the following categories:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...existingCategories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCategoryName(cat),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              Text(
                'Starting new habits will replace your existing ones. Do you want to continue?',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startHabits();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Replace Habits',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatCategoryName(String categoryStr) {
    // Convert camelCase to Title Case
    return categoryStr
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _showPremiumDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Premium Feature',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock all habit categories with Premium!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildPremiumFeature(
                Icons.check_circle,
                'Access all 10 habit categories',
                isDark,
              ),
              _buildPremiumFeature(
                Icons.check_circle,
                'Unlimited motivational quotes',
                isDark,
              ),
              _buildPremiumFeature(
                Icons.check_circle,
                'Track habits across all life areas',
                isDark,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                NavigationHelper.pushRoute(context, const PremiumAppScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumFeature(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: kPrimaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    setState(() {
      currentStep = 0;
    });
  }

  void _updateCategoryColorsForTheme(bool isDark) {
    // Update colors based on theme
    for (int i = 0; i < habitCategories.length; i++) {
      final category = habitCategories[i];
      if (isDark) {
        // Dark theme: use darker background with lighter icons
        habitCategories[i] = CategoryTemplate(
          category: category.category,
          name: category.name,
          description: category.description,
          icon: category.icon,
          color: category.iconColor.withOpacity(0.2),
          iconColor: category.iconColor.withOpacity(0.8),
        );
      } else {
        // Light theme: restore original colors
        habitCategories[i] = _getOriginalCategoryTemplate(category.category);
      }
    }
  }

  CategoryTemplate _getOriginalCategoryTemplate(HabitCategory category) {
    switch (category) {
      case HabitCategory.healthFitness:
        return CategoryTemplate(
          category: HabitCategory.healthFitness,
          name: 'Health & Fitness',
          description: 'Physical wellness and exercise',
          icon: Icons.fitness_center,
          color: Colors.orange.shade100,
          iconColor: Colors.orange.shade700,
        );
      case HabitCategory.mindEmotions:
        return CategoryTemplate(
          category: HabitCategory.mindEmotions,
          name: 'Mind & Emotions',
          description: 'Mental wellness and emotional health',
          icon: Icons.psychology,
          color: Colors.blue.shade100,
          iconColor: Colors.blue.shade700,
        );
      case HabitCategory.learningGrowth:
        return CategoryTemplate(
          category: HabitCategory.learningGrowth,
          name: 'Learning & Growth',
          description: 'Education and personal development',
          icon: Icons.school,
          color: Colors.purple.shade100,
          iconColor: Colors.purple.shade700,
        );
      case HabitCategory.productivityWork:
        return CategoryTemplate(
          category: HabitCategory.productivityWork,
          name: 'Productivity & Work',
          description: 'Efficiency and professional development',
          icon: Icons.trending_up,
          color: Colors.green.shade100,
          iconColor: Colors.green.shade700,
        );
      case HabitCategory.financeMoney:
        return CategoryTemplate(
          category: HabitCategory.financeMoney,
          name: 'Finance & Money',
          description: 'Financial wellness and management',
          icon: Icons.attach_money,
          color: Colors.teal.shade100,
          iconColor: Colors.teal.shade700,
        );
      case HabitCategory.lifestyleRoutine:
        return CategoryTemplate(
          category: HabitCategory.lifestyleRoutine,
          name: 'Lifestyle & Routine',
          description: 'Daily routines and lifestyle choices',
          icon: Icons.schedule,
          color: Colors.pink.shade100,
          iconColor: Colors.pink.shade700,
        );
      case HabitCategory.relationshipsSocial:
        return CategoryTemplate(
          category: HabitCategory.relationshipsSocial,
          name: 'Relationships & Social',
          description: 'Social connections and relationships',
          icon: Icons.people,
          color: Colors.red.shade100,
          iconColor: Colors.red.shade700,
        );
      case HabitCategory.creativityHobbies:
        return CategoryTemplate(
          category: HabitCategory.creativityHobbies,
          name: 'Creativity & Hobbies',
          description: 'Creative expression and hobbies',
          icon: Icons.palette,
          color: Colors.deepOrange.shade100,
          iconColor: Colors.deepOrange.shade700,
        );
      case HabitCategory.contributionImpact:
        return CategoryTemplate(
          category: HabitCategory.contributionImpact,
          name: 'Contribution & Impact',
          description: 'Making a positive difference',
          icon: Icons.volunteer_activism,
          color: Colors.brown.shade100,
          iconColor: Colors.brown.shade700,
        );
      case HabitCategory.spiritualityMindfulness:
        return CategoryTemplate(
          category: HabitCategory.spiritualityMindfulness,
          name: 'Spirituality & Mindfulness',
          description: 'Spiritual practices and mindfulness',
          icon: Icons.spa,
          color: Colors.indigo.shade100,
          iconColor: Colors.indigo.shade700,
        );
    }
  }

  Future<void> _startHabits() async {
    debugPrint('\n🚀 ═══════════════════════════════════════════════════════════');
    debugPrint('🚀 START BUILDING HABITS - FETCHING QUOTES');
    debugPrint('🚀 ═══════════════════════════════════════════════════════════');
    debugPrint('📋 Selected Categories: ${selectedCategories.length}');

    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    // Fetch and merge quotes from ALL selected categories
    mergedQuotes = [];

    for (var category in selectedCategories) {
      debugPrint('\n📂 Processing: ${_getCategoryName(category)}');

      final quotes = await _quoteService.getQuotesForCategory(category);
      mergedQuotes.addAll(quotes);

      debugPrint('   ✓ Fetched ${quotes.length} quotes');
      debugPrint('   📊 Running total: ${mergedQuotes.length} quotes');
    }

    // Shuffle the merged quotes
    mergedQuotes.shuffle();

    debugPrint('\n🎲 ═══════════════════════════════════════════════════════════');
    debugPrint('🎲 QUOTES MERGED & SHUFFLED');
    debugPrint('🎲 ═══════════════════════════════════════════════════════════');
    debugPrint('📊 Total quotes to serve: ${mergedQuotes.length}');
    debugPrint('📂 From ${selectedCategories.length} categories');

    if (mergedQuotes.isNotEmpty) {
      debugPrint('\n📝 Sample quotes (first 5):');
      for (int i = 0; i < (mergedQuotes.length > 5 ? 5 : mergedQuotes.length); i++) {
        debugPrint('  ${i + 1}. "${mergedQuotes[i].quote}"');
        debugPrint('     - From: ${mergedQuotes[i].categoryName} (ID: ${mergedQuotes[i].categoryId})');
      }
    } else {
      debugPrint('⚠️  WARNING: No quotes found! Database might be empty.');
    }

    debugPrint('\n🎲 ═══════════════════════════════════════════════════════════\n');

    // 🎯 STORE MERGED QUOTES IN DATA REPOSITORY FOR PHRASER VIEW
    debugPrint('💾 Storing ${mergedQuotes.length} quotes in DataRepository...');
    DataRepository().updateCurrentPhrasersList(mergedQuotes, fromHabits: true);
    DataRepository().saveOriginalPhrasersList();

    // 🎯 SAVE MERGED QUOTES TO DATABASE (current_phrasers table)
    try {
      final database = FloorDB.instance.floorDatabase;
      final currentPhraserDAO = database.currentPhraserDAO;

      // Clear old current phrasers and save new ones
      await currentPhraserDAO.deleteCurrentPhrasers();
      await currentPhraserDAO.insertAllCurrentPhrasers(mergedQuotes);

      debugPrint('✅ Quotes saved to database (current_phrasers table)');
    } catch (e) {
      debugPrint('❌ Error saving quotes to database: $e');
    }

    debugPrint('✅ Quotes stored successfully! Phraser view will display these quotes.');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Create default habits for each selected category
    List<String> defaultHabits = [];

    for (var category in selectedCategories) {
      switch (category) {
        case HabitCategory.healthFitness:
          defaultHabits.addAll(['Drink Water', 'Exercise', 'Sleep Well']);
          break;
        case HabitCategory.mindEmotions:
          defaultHabits.addAll(['Journal', 'Practice Gratitude']);
          break;
        case HabitCategory.learningGrowth:
          defaultHabits.addAll(['Read Daily']);
          break;
        case HabitCategory.productivityWork:
          defaultHabits.addAll(['Digital Detox']);
          break;
        case HabitCategory.financeMoney:
          defaultHabits.addAll(['Track Expenses']);
          break;
        case HabitCategory.lifestyleRoutine:
          defaultHabits.addAll(['Early Rise']);
          break;
        case HabitCategory.relationshipsSocial:
          defaultHabits.addAll(['Connect']);
          break;
        case HabitCategory.creativityHobbies:
          defaultHabits.addAll(['Creative Time']);
          break;
        case HabitCategory.contributionImpact:
          defaultHabits.addAll(['Volunteer']);
          break;
        case HabitCategory.spiritualityMindfulness:
          defaultHabits.addAll(['Meditate']);
          break;
      }
    }

    // 🎯 SAVE HABITS TO DATABASE
    try {
      final database = FloorDB.instance.floorDatabase;
      final habitsDAO = database.habitsDAO;
      final streakDAO = database.habitStreakDAO;

      // Deactivate all existing habits first
      await habitsDAO.deactivateAllHabits(DateTime.now().toIso8601String());

      debugPrint('\n💾 ═══════════════════════════════════════════════════════════');
      debugPrint('💾 SAVING HABITS TO DATABASE');
      debugPrint('💾 ═══════════════════════════════════════════════════════════');

      // Get category mapping to get the quote category IDs
      final categoryMapping = _quoteService.getCategoryMapping();

      // Create and save habits for each selected category
      for (var category in selectedCategories) {
        // Get category IDs for this habit category
        final categoryIds = categoryMapping[category] ?? [];
        final categoryIdsStr = categoryIds.join(',');

        final habit = Habit(
          habitId: const Uuid().v4(),
          name: _getCategoryName(category),
          description: 'Daily habit for ${_getCategoryName(category)}',
          category: category.toString().split('.').last,
          frequency: 'daily',
          difficulty: 'beginner',
          targetValue: 1, // Complete once per day
          unit: 'time',
          isActive: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          colorHex: '#4A90E2',
          motivationalQuote: mergedQuotes.isNotEmpty ? mergedQuotes.first.quote : null,
          tags: categoryIdsStr, // Store category IDs for quote fetching
        );

        await habitsDAO.insertHabit(habit);

        // Create initial streak record
        final streak = HabitStreak(
          streakId: const Uuid().v4(),
          habitId: habit.habitId,
          currentStreak: 0,
          longestStreak: 0,
          lastCompletedDate: '',
          streakStartDate: DateTime.now().toIso8601String().split('T')[0],
          updatedAt: DateTime.now().toIso8601String(),
        );

        await streakDAO.insertStreak(streak);

        debugPrint('✅ Saved habit: ${habit.name} (ID: ${habit.habitId})');
      }

      debugPrint('💾 ═══════════════════════════════════════════════════════════\n');
    } catch (e) {
      debugPrint('❌ Error saving habits to database: $e');
    }

    // Save both categories and habits to preferences (for backward compatibility)
    final selectedCategoriesList = selectedCategories.map((c) => c.toString().split('.').last).toList();
    Preferences.instance.setStringList('user_categories', selectedCategoriesList);
    Preferences.instance.setStringList('user_habits', defaultHabits);

    // Reset carousel position to start showing from first quote
    Preferences.instance.currentPhraserPosition = 0;

    // Close loading dialog
    Get.back();

    // Show success message
    Get.snackbar(
      'Habits Created!',
      '${defaultHabits.length} habits set up with ${mergedQuotes.length} motivational quotes ready!',
      backgroundColor: kPrimaryColor.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );

    // Navigate back to home (check mounted before using context)
    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _getCategoryName(HabitCategory category) {
    final template = habitCategories.firstWhere((t) => t.category == category);
    return template.name;
  }
}

class HabitTemplate {
  final String emoji;
  final String name;
  final String description;
  final Color color;

  HabitTemplate(this.emoji, this.name, this.description, this.color);
}
