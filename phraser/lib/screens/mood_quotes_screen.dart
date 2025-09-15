import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/consts/colors.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/preferences.dart';
import '../util/utils.dart';

class MoodQuotesScreen extends StatefulWidget {
  const MoodQuotesScreen({super.key});

  @override
  State<MoodQuotesScreen> createState() => _MoodQuotesScreenState();
}

class _MoodQuotesScreenState extends State<MoodQuotesScreen> {
  String? selectedMood;
  List<MoodOption> moodOptions = [
    MoodOption('😊', 'Happy', 'Joyful and optimistic quotes', Colors.yellow.shade100),
    MoodOption('😢', 'Sad', 'Comforting and healing quotes', Colors.blue.shade100),
    MoodOption('😡', 'Angry', 'Calming and peaceful quotes', Colors.red.shade100),
    MoodOption('😰', 'Anxious', 'Reassuring and grounding quotes', Colors.purple.shade100),
    MoodOption('💪', 'Motivated', 'Inspiring and energizing quotes', Colors.green.shade100),
    MoodOption('😴', 'Tired', 'Restoring and peaceful quotes', Colors.grey.shade100),
    MoodOption('🤔', 'Thoughtful', 'Deep and reflective quotes', Colors.indigo.shade100),
    MoodOption('❤️', 'Loving', 'Warm and affectionate quotes', Colors.pink.shade100),
    MoodOption('😌', 'Peaceful', 'Serene and mindful quotes', Colors.teal.shade100),
    MoodOption('🔥', 'Energetic', 'Dynamic and powerful quotes', Colors.orange.shade100),
    MoodOption('🌱', 'Growing', 'Personal development quotes', Colors.lightGreen.shade100),
    MoodOption('🎯', 'Focused', 'Goal-oriented and clarity quotes', Colors.cyan.shade100),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mood-Based Quotes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
              color: isDark ? Theme.of(context).cardColor : Colors.white,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: moodOptions.length,
                itemBuilder: (context, index) {
                  final mood = moodOptions[index];
                  final isSelected = selectedMood == mood.name;
                  
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
                              mood.emoji,
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                mood.name,
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
                                mood.description,
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
            ),
          ),

          // Continue Button
          if (selectedMood != null)
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

  void _selectMood(MoodOption mood) {
    setState(() {
      selectedMood = selectedMood == mood.name ? null : mood.name;
    });
  }

  void _showMoodQuotes() {
    if (selectedMood == null) return;

    // Filter quotes based on mood (simplified filtering logic)
    final allQuotes = DataRepository().currentPhrasersList;
    final moodKeywords = _getMoodKeywords(selectedMood!);
    
    final filteredQuotes = allQuotes.where((quote) {
      final lowerQuote = quote.quote.toLowerCase();
      return moodKeywords.any((keyword) => lowerQuote.contains(keyword));
    }).toList();

    // If no filtered quotes found, show all quotes with a message
    if (filteredQuotes.isEmpty) {
      _showNoQuotesFoundDialog();
      return;
    }

    // Update quotes list and navigate back to home
    DataRepository().updateCurrentPhrasersList(filteredQuotes);
    Preferences.instance.currentPhraserPosition = 0;

    // Show success message
    Get.snackbar(
      'Mood Set!',
      'Showing ${filteredQuotes.length} quotes for your $selectedMood mood',
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
          'We don\'t have specific quotes for your $selectedMood mood right now, but all our quotes can inspire you in different ways!',
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

class MoodOption {
  final String emoji;
  final String name;
  final String description;
  final Color color;

  MoodOption(this.emoji, this.name, this.description, this.color);
}