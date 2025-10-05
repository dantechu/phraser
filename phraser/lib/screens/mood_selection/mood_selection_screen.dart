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

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  // Optimize: Use Get.find to avoid recreating if already exists
  late final MoodSelectionViewModel _viewModel;

  MoodType? selectedMood;
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(int.parse(mapping!.colorHex
                                      .replaceAll('#', '0xFF')))
                                  : (isDark ? Colors.grey[800] : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Color(int.parse(mapping!.colorHex
                                        .replaceAll('#', '0xFF')))
                                    : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Color(int.parse(mapping!.colorHex
                                              .replaceAll('#', '0xFF')))
                                          .withOpacity(0.3)
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
                                        : (isDark ? Colors.white : Colors.black),
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

  void _selectMood(MoodType mood) {
    setState(() {
      selectedMood = mood;
    });
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
