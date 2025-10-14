import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/consts/colors.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/view_model/mood_list_view_model.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/preferences.dart';
import '../services/model/mood_api_model.dart';

class MoodQuotesScreen extends StatefulWidget {
  const MoodQuotesScreen({super.key});

  @override
  State<MoodQuotesScreen> createState() => _MoodQuotesScreenState();
}

class _MoodQuotesScreenState extends State<MoodQuotesScreen> {
  final _moodViewModel = Get.put(MoodListViewModel());
  String? selectedMoodId;
  String? selectedMoodTitle;

  @override
  void initState() {
    super.initState();
    _moodViewModel.getMoods();
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood-Based Quotes',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),

        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
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
                Text(
                  'Select your mood to discover quotes that resonate with you',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Mood Selection Grid
          Expanded(
            child: GetBuilder<MoodListViewModel>(
              builder: (vm) {
                if (vm.isMoodsLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  );
                }

                if (vm.errorMessage != null) {
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
                          vm.errorMessage!,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => vm.getMoods(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (vm.currentMoodsList.isEmpty) {
                  return Center(
                    child: Text(
                      'No moods available',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: vm.currentMoodsList.length,
                    itemBuilder: (context, index) {
                      final mood = vm.currentMoodsList[index];
                      final isSelected = selectedMoodId == mood.moodId;

                      return GestureDetector(
                        onTap: () => _selectMood(mood),
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
                                Text(
                                  mood.moodIcon,
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 24,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  child: Text(
                                    mood.moodTitle,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
                                    '${mood.totalPhrasers} quotes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).primaryColorDark.withOpacity(0.6),
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
              },
            ),
          ),

          // Continue Button
          if (selectedMoodId != null)
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showMoodQuotes,
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
                    'Show Quotes for My Mood',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _selectMood(MoodItem mood) {
    setState(() {
      if (selectedMoodId == mood.moodId) {
        selectedMoodId = null;
        selectedMoodTitle = null;
      } else {
        selectedMoodId = mood.moodId;
        selectedMoodTitle = mood.moodTitle;
      }
    });
  }

  void _showMoodQuotes() {
    if (selectedMoodTitle == null) return;

    // Filter quotes based on mood (simplified filtering logic)
    final allQuotes = DataRepository().currentPhrasersList;
    final moodKeywords = _getMoodKeywords(selectedMoodTitle!);

    final filteredQuotes = allQuotes.where((quote) {
      final lowerQuote = quote.quote.toLowerCase();
      return moodKeywords.any((keyword) => lowerQuote.contains(keyword));
    }).toList();

    // If no filtered quotes found, show all quotes with a message
    if (filteredQuotes.isEmpty) {
      _showNoQuotesFoundDialog();
      return;
    }

    // Shuffle the filtered quotes to randomize the order
    filteredQuotes.shuffle();

    // Update quotes list and navigate back to home
    DataRepository().updateCurrentPhrasersList(filteredQuotes);
    Preferences.instance.currentPhraserPosition = 0;

    // Show success message
    Get.snackbar(
      'Mood Set!',
      'Showing ${filteredQuotes.length} quotes for your $selectedMoodTitle mood',
      backgroundColor: kPrimaryColor.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );

    // Navigate back to home
    Navigator.pop(context);
  }

  List<String> _getMoodKeywords(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return ['joy', 'happiness', 'smile', 'laugh', 'celebrate', 'positive', 'bright'];
      case 'sad':
        return ['comfort', 'heal', 'hope', 'strength', 'overcome', 'better'];
      case 'angry':
        return ['peace', 'calm', 'patience', 'forgive', 'understanding'];
      case 'anxious':
        return ['peace', 'calm', 'breathe', 'present', 'worry', 'fear'];
      case 'motivated':
        return ['success', 'goal', 'achieve', 'work', 'effort', 'dream', 'ambition'];
      case 'tired':
        return ['rest', 'sleep', 'restore', 'energy', 'renewal', 'peace'];
      case 'thoughtful':
        return ['wisdom', 'think', 'reflect', 'understand', 'learn', 'mind'];
      case 'loving':
        return ['love', 'heart', 'care', 'kindness', 'compassion', 'family'];
      case 'peaceful':
        return ['peace', 'calm', 'quiet', 'serene', 'tranquil', 'mindful'];
      case 'energetic':
        return ['energy', 'power', 'strong', 'active', 'dynamic', 'force'];
      case 'growing':
        return ['grow', 'learn', 'develop', 'improve', 'progress', 'change'];
      case 'focused':
        return ['focus', 'goal', 'clarity', 'purpose', 'direction', 'aim'];
      default:
        return ['life', 'wisdom', 'truth'];
    }
  }

  void _showNoQuotesFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('No Specific Quotes Found'),
        content: Text(
          'We don\'t have specific quotes for your $selectedMoodTitle mood right now, but all our quotes can inspire you in different ways!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Show All Quotes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Try Another Mood',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}