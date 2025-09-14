import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/consts/colors.dart' show AppColors;
import '../../services/model/habit_model.dart';
import '../../util/colors.dart';
import '../../widgets/simple_widgets.dart';
import 'view_model/habit_builder_view_model.dart';

class HabitSetupScreen extends StatefulWidget {
  const HabitSetupScreen({Key? key}) : super(key: key);

  @override
  State<HabitSetupScreen> createState() => _HabitSetupScreenState();
}

class _HabitSetupScreenState extends State<HabitSetupScreen> {
  final HabitBuilderViewModel _viewModel = Get.put(HabitBuilderViewModel());
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Build Your Habit',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<HabitBuilderViewModel>(
        builder: (vm) => Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                children: [
                  _buildWelcomeStep(),
                  _buildCategoryStep(),
                  _buildTemplateStep(),
                  _buildCustomizationStep(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _handleNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentStep == 3 ? 'Create Habit' : 'Next',
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
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 32),
          Text(
            'Let\'s Build Your First Habit',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Habits are the compound interest of self-improvement. Start small, stay consistent, and transform your life one day at a time.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choose from world-class habit templates or create your own custom habit.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
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

  Widget _buildCategoryStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Focus Area',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What area of your life would you like to improve?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: HabitCategory.values.length,
              itemBuilder: (context, index) {
                final category = HabitCategory.values[index];
                final isSelected = _viewModel.selectedCategory == category;

                return GestureDetector(
                  onTap: () => _viewModel.selectCategory(category),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 40,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getCategoryName(category),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateStep() {
    final templates = HabitTemplate.getDefaultTemplates()
        .where((template) => template.category == _viewModel.selectedCategory)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Template',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a proven habit template or create a custom one',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: templates.length + 1, // +1 for custom option
              itemBuilder: (context, index) {
                if (index == templates.length) {
                  // Custom habit option
                  return _buildCustomHabitOption();
                }

                final template = templates[index];
                final isSelected = _viewModel.selectedTemplate == template;

                return GestureDetector(
                  onTap: () => _viewModel.selectTemplate(template),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
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
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(int.parse(
                                    template.colorHex.replaceAll('#', '0xFF'))),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  const Icon(Icons.star, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${template.targetValue} ${template.unit} ${template.frequency.toString().split('.').last}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: AppColors.primaryColor),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          template.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getDifficultyLabel(template.difficulty),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHabitOption() {
    final isSelected = _viewModel.isCustomHabit;

    return GestureDetector(
      onTap: () => _viewModel.selectCustomHabit(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Custom Habit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Design your own unique habit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize Your Habit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fine-tune the details to make it perfect for you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit name
                  _buildTextField(
                    'Habit Name',
                    'Enter your habit name',
                    _viewModel.habitNameController,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildTextField(
                    'Description (Optional)',
                    'Why is this habit important to you?',
                    _viewModel.habitDescriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Target and unit
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Target',
                          '10',
                          _viewModel.targetValueController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Unit',
                          _viewModel.selectedUnit,
                          [
                            'minutes',
                            'times',
                            'pages',
                            'glasses',
                            'steps',
                            'hours'
                          ],
                          (value) => _viewModel.setUnit(value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Frequency
                  _buildDropdown(
                    'Frequency',
                    _viewModel.selectedFrequency?.toString().split('.').last,
                    ['daily', 'weekly', 'monthly'],
                    (value) => _viewModel.setFrequency(
                      HabitFrequency.values.firstWhere(
                        (e) => e.toString().split('.').last == value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Difficulty
                  _buildDropdown(
                    'Difficulty Level',
                    _viewModel.selectedDifficulty?.toString().split('.').last,
                    ['beginner', 'intermediate', 'advanced'],
                    (value) => _viewModel.setDifficulty(
                      HabitDifficulty.values.firstWhere(
                        (e) => e.toString().split('.').last == value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item.capitalize!),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Welcome step
      case 1:
        return _viewModel.selectedCategory != null;
      case 2:
        return _viewModel.selectedTemplate != null || _viewModel.isCustomHabit;
      case 3:
        return _viewModel.habitNameController.text.isNotEmpty &&
            _viewModel.targetValueController.text.isNotEmpty &&
            _viewModel.selectedUnit != null &&
            _viewModel.selectedFrequency != null &&
            _viewModel.selectedDifficulty != null;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createHabit();
    }
  }

  void _createHabit() async {
    try {
      await _viewModel.createHabit();
      Get.back();
      Get.snackbar(
        'Success',
        'Your habit has been created! Start building your streak today.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create habit. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
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
        return category.toString().split('.').last.capitalize!;
    }
  }

  String _getDifficultyLabel(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.beginner:
        return 'Beginner Friendly';
      case HabitDifficulty.intermediate:
        return 'Intermediate';
      case HabitDifficulty.advanced:
        return 'Advanced';
      default:
        return difficulty.toString().split('.').last.capitalize!;
    }
  }
}
