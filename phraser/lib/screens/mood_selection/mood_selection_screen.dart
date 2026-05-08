import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/consts/colors.dart';
import '../../services/model/mood_api_model.dart';
import '../../services/model/mood_model.dart';
import '../../services/view_model/mood_list_view_model.dart';
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

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  // Optimize: Use Get.find to avoid recreating if already exists
  late final MoodSelectionViewModel _viewModel;
  late final MoodListViewModel _moodListViewModel;

  MoodType? selectedMood;
  String? selectedMoodId;
  String? selectedMoodTitle;
  MoodIntensity selectedIntensity = MoodIntensity.medium;

  @override
  void initState() {
    super.initState();

    // Optimize: Initialize view model efficiently
    try {
      _viewModel = Get.find<MoodSelectionViewModel>();
    } catch (e) {
      _viewModel = Get.put(MoodSelectionViewModel());
    }

    // Initialize mood list view model
    try {
      _moodListViewModel = Get.find<MoodListViewModel>();
    } catch (e) {
      _moodListViewModel = Get.put(MoodListViewModel());
    }

    // Load moods from API
    _moodListViewModel.getMoods();

    // Initialize with current mood selection if available
    selectedMood = _viewModel.currentMood;
    selectedIntensity = _viewModel.currentIntensity ?? MoodIntensity.medium;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (widget.showAsBottomSheet) {
      return _buildBottomSheet();
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'How are you feeling?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildMoodSelection()),
    );
  }

  Widget _buildBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              color: isDark ? Colors.grey[600] : Colors.grey[300],
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
                color: isDark ? Colors.white : Colors.black,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GetBuilder<MoodSelectionViewModel>(
      builder: (vm) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [


            // Mood grid
            Expanded(
              child: GetBuilder<MoodListViewModel>(
                builder: (moodListVm) {
                  // Show loading state
                  if (moodListVm.isMoodsLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    );
                  }

                  // Show error state
                  if (moodListVm.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            moodListVm.errorMessage!,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => moodListVm.getMoods(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show empty state
                  if (moodListVm.currentMoodsList.isEmpty) {
                    return Center(
                      child: Text(
                        'No moods available',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    );
                  }

                  // Show moods grid from API
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: moodListVm.currentMoodsList.length,
                    itemBuilder: (context, index) {
                      final mood = moodListVm.currentMoodsList[index];
                      final isSelected = selectedMoodId == mood.moodId;

                      return GestureDetector(
                        onTap: () => _selectMoodFromApi(mood),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kPrimaryColor
                                : (isDark ? Colors.grey[800] : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? kPrimaryColor
                                  : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? kPrimaryColor.withOpacity(0.3)
                                    : (isDark
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.05)),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: isSelected ? 40 : 36,
                                alignment: Alignment.center,
                                child: Text(
                                  mood.moodIcon.isNotEmpty ? mood.moodIcon : '😊',
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 28,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood.moodTitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${mood.totalPhrasers} quotes',
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
                  );
                },
              ),
            ),

            // Intensity selector (shown when mood is selected)
            if (selectedMoodId != null) ...[
              const SizedBox(height: 24),
              _buildIntensitySelector(),
            ],

            const SizedBox(height: 24),

            // Continue button
            if (selectedMoodId != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How intense is this feeling?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: MoodIntensity.values.map((intensity) {
            final isSelected = selectedIntensity == intensity;

            return Expanded(
              child: GestureDetector(
                onTap: () => _selectIntensity(intensity),
                child: Container(
                  margin: EdgeInsets.only(
                    right: intensity != MoodIntensity.values.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? kPrimaryColor 
                        : (isDark ? Colors.grey[800] : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? kPrimaryColor
                          : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
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
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white : Colors.black),
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

  void _selectMoodFromApi(MoodItem mood) {
    setState(() {
      selectedMoodId = mood.moodId;
      selectedMoodTitle = mood.moodTitle;
      // Try to map to enum for backward compatibility
      try {
        selectedMood = MoodType.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == mood.moodTitle.toLowerCase(),
          orElse: () => MoodType.happy,
        );
      } catch (e) {
        selectedMood = MoodType.happy; // fallback
      }
    });
  }

  void _selectIntensity(MoodIntensity intensity) {
    setState(() {
      selectedIntensity = intensity;
    });
  }

  void _handleContinue() {
    if (selectedMood != null && selectedMoodTitle != null) {
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
        'moodTitle': selectedMoodTitle,
      });
    }
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
