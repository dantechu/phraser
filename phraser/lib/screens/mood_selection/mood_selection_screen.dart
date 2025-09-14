import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/consts/colors.dart';
import '../../services/model/mood_model.dart';
import '../../util/colors.dart';
import 'view_model/mood_selection_view_model.dart';

class MoodSelectionScreen extends StatefulWidget {
  final Function(MoodType, MoodIntensity)? onMoodSelected;
  final bool showAsBottomSheet;

  const MoodSelectionScreen({
    Key? key,
    this.onMoodSelected,
    this.showAsBottomSheet = false,
  }) : super(key: key);

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen>
    with TickerProviderStateMixin {
  final MoodSelectionViewModel _viewModel = Get.put(MoodSelectionViewModel());
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  MoodType? selectedMood;
  MoodIntensity selectedIntensity = MoodIntensity.medium;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsBottomSheet) {
      return _buildBottomSheet();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'How are you feeling?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildMoodSelection(),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'How are you feeling right now?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Content
          Flexible(
            child: _buildMoodSelection(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelection() {
    return GetBuilder<MoodSelectionViewModel>(
      builder: (vm) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mood selection explanation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select your current mood to get personalized quotes that match how you\'re feeling.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mood grid
            Expanded(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: MoodType.values.length,
                      itemBuilder: (context, index) {
                        final mood = MoodType.values[index];
                        final mapping =
                            MoodQuoteMapping.getMappingForMood(mood);
                        final isSelected = selectedMood == mood;

                        return GestureDetector(
                          onTap: () => _selectMood(mood),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(int.parse(mapping!.colorHex
                                      .replaceAll('#', '0xFF')))
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Color(int.parse(mapping!.colorHex
                                        .replaceAll('#', '0xFF')))
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Color(int.parse(mapping!.colorHex
                                              .replaceAll('#', '0xFF')))
                                          .withOpacity(0.3)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: isSelected ? 12 : 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mapping?.emoji ?? '😊',
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getMoodName(mood),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (isSelected) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    mapping?.description ?? '',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Intensity selector (shown when mood is selected)
            if (selectedMood != null) ...[
              const SizedBox(height: 24),
              _buildIntensitySelector(),
            ],

            const SizedBox(height: 24),

            // Continue button
            if (selectedMood != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get Matching Quotes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How intense is this feeling?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: MoodIntensity.values.map((intensity) {
            final isSelected = selectedIntensity == intensity;

            return Expanded(
              child: GestureDetector(
                onTap: () => _selectIntensity(intensity),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: intensity != MoodIntensity.values.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getIntensityIcon(intensity),
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getIntensityName(intensity),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _selectMood(MoodType mood) {
    setState(() {
      selectedMood = mood;
    });

    // Animate selection
    _animationController.reset();
    _animationController.forward();
  }

  void _selectIntensity(MoodIntensity intensity) {
    setState(() {
      selectedIntensity = intensity;
    });
  }

  void _handleContinue() {
    if (selectedMood != null) {
      // Save mood entry
      _viewModel.saveMoodEntry(selectedMood!, selectedIntensity);

      // Call callback if provided
      if (widget.onMoodSelected != null) {
        widget.onMoodSelected!(selectedMood!, selectedIntensity);
      }

      // Navigate back or close
      Navigator.pop(context, {
        'mood': selectedMood,
        'intensity': selectedIntensity,
      });
    }
  }

  String _getMoodName(MoodType mood) {
    return mood.toString().split('.').last.capitalize!;
  }

  String _getIntensityName(MoodIntensity intensity) {
    switch (intensity) {
      case MoodIntensity.low:
        return 'Mild';
      case MoodIntensity.medium:
        return 'Moderate';
      case MoodIntensity.high:
        return 'Intense';
      default:
        return intensity.toString().split('.').last.capitalize!;
    }
  }

  String _getIntensityIcon(MoodIntensity intensity) {
    switch (intensity) {
      case MoodIntensity.low:
        return '🌱';
      case MoodIntensity.medium:
        return '🌿';
      case MoodIntensity.high:
        return '🌳';
      default:
        return '🌿';
    }
  }
}
