import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../services/model/mood_model.dart';
import '../../../services/model/phreasers_list_model.dart';
import '../../../services/model/data_repository.dart';

class MoodSelectionViewModel extends GetxController {
  // Current mood state
  MoodType? currentMood;
  MoodIntensity? currentIntensity;
  
  // Mood history
  List<MoodEntry> moodHistory = [];
  
  // Filtered quotes based on mood
  List<Phraser> moodFilteredQuotes = [];

  @override
  void onInit() {
    super.onInit();
    _loadMoodHistory();
  }

  Future<void> saveMoodEntry(MoodType mood, MoodIntensity intensity) async {
    final entry = MoodEntry(
      moodId: const Uuid().v4(),
      mood: mood.toString().split('.').last,
      intensity: intensity.toString().split('.').last,
      date: DateTime.now().toIso8601String().split('T')[0],
      timestamp: DateTime.now().toIso8601String(),
    );

    // Save to database
    await _saveMoodToDatabase(entry);
    
    // Update current state
    currentMood = mood;
    currentIntensity = intensity;
    
    // Add to history
    moodHistory.insert(0, entry);
    
    // Filter quotes based on mood
    await _filterQuotesByMood();
    
    update();
  }

  Future<void> _filterQuotesByMood() async {
    if (currentMood == null) return;

    // Save original quotes if not already saved
    DataRepository().saveOriginalPhrasersList();

    // Get mood-specific tags
    final moodTags = MoodQuoteMapping.getQuoteTagsForMood(currentMood!);
    
    // Filter quotes from data repository
    final allQuotes = DataRepository().currentPhrasersList;
    
    if (allQuotes.isEmpty) {
      print('No quotes available to filter');
      return;
    }
    
    moodFilteredQuotes = allQuotes.where((quote) {
      // Check if quote has mood tags that match current mood
      if (quote.moodTagsList.isNotEmpty) {
        return quote.moodTagsList.any((tag) => 
          moodTags.contains(tag.toLowerCase())
        );
      }
      
      // Enhanced fallback: use traditional tags with broader matching
      final quoteTags = quote.tags.toLowerCase().split(',');
      final quoteText = quote.quote.toLowerCase();
      
      // Check both tags and quote text for mood-related keywords
      final hasTagMatch = quoteTags.any((tag) => 
        moodTags.contains(tag.trim())
      );
      
      final hasTextMatch = moodTags.any((moodTag) =>
        quoteText.contains(moodTag.toLowerCase())
      );
      
      return hasTagMatch || hasTextMatch;
    }).toList();

    // If no specific matches found, include quotes with general positive/motivational content
    if (moodFilteredQuotes.isEmpty) {
      final generalTags = ['motivation', 'inspiration', 'positive', 'hope', 'strength', 'wisdom', 'peace', 'life'];
      
      moodFilteredQuotes = allQuotes.where((quote) {
        final quoteTags = quote.tags.toLowerCase().split(',');
        final quoteText = quote.quote.toLowerCase();
        
        return generalTags.any((tag) =>
          quoteTags.any((quoteTag) => quoteTag.trim().contains(tag)) ||
          quoteText.contains(tag)
        );
      }).toList();
    }

    // If still no matches, take a random sample of quotes
    if (moodFilteredQuotes.isEmpty && allQuotes.isNotEmpty) {
      moodFilteredQuotes = allQuotes.take(20).toList();
    }

    // Sort by intensity match if available
    if (currentIntensity != null && moodFilteredQuotes.isNotEmpty) {
      final targetIntensity = _getIntensityLevel(currentIntensity!);
      moodFilteredQuotes.sort((a, b) {
        final aMatch = a.matchesIntensity(targetIntensity);
        final bMatch = b.matchesIntensity(targetIntensity);
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return 0;
      });
    }
    
    print('Filtered ${moodFilteredQuotes.length} quotes for mood: ${currentMood?.toString().split('.').last}');
    update();
  }

  int _getIntensityLevel(MoodIntensity intensity) {
    switch (intensity) {
      case MoodIntensity.low:
        return 2;
      case MoodIntensity.medium:
        return 3;
      case MoodIntensity.high:
        return 4;
      default:
        return 3;
    }
  }

  Future<void> _saveMoodToDatabase(MoodEntry entry) async {
    // TODO: Implement database save
    // This would typically use Floor database or your preferred database solution
    // Example:
    // final database = FloorDB.instance.floorDatabase;
    // final moodDAO = database.moodEntriesDAO;
    // await moodDAO.insertMoodEntry(entry);
    
    // For now, we'll just simulate a delay
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _loadMoodHistory() async {
    // TODO: Implement database load
    // Load mood history from database
    // moodHistory = await database.moodEntriesDAO.getAllMoodEntries();
    // 
    // If we have recent mood data, set current mood
    // if (moodHistory.isNotEmpty) {
    //   final recent = moodHistory.first;
    //   currentMood = recent.moodEnum;
    //   currentIntensity = recent.intensityEnum;
    //   await _filterQuotesByMood();
    // }
    
    update();
  }

  // Get mood statistics
  Map<MoodType, int> getMoodFrequency({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentMoods = moodHistory.where((entry) {
      final entryDate = DateTime.parse(entry.timestamp);
      return entryDate.isAfter(cutoffDate);
    }).toList();

    final frequency = <MoodType, int>{};
    for (final entry in recentMoods) {
      final mood = entry.moodEnum;
      frequency[mood] = (frequency[mood] ?? 0) + 1;
    }
    
    return frequency;
  }

  // Get mood trends
  List<MoodEntry> getRecentMoods({int limit = 10}) {
    return moodHistory.take(limit).toList();
  }

  // Get dominant mood
  MoodType? getDominantMood({int days = 7}) {
    final frequency = getMoodFrequency(days: days);
    if (frequency.isEmpty) return null;
    
    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Get mood insights
  String getMoodInsight() {
    if (moodHistory.isEmpty) {
      return 'Start tracking your moods to get personalized insights!';
    }

    final recentMoods = getRecentMoods(limit: 7);
    final dominantMood = getDominantMood(days: 7);
    
    if (dominantMood == null) {
      return 'Track more moods to see patterns and insights.';
    }

    final mapping = MoodQuoteMapping.getMappingForMood(dominantMood);
    
    switch (dominantMood) {
      case MoodType.happy:
        return 'You\'ve been feeling joyful lately! ${mapping?.emoji} Keep embracing the positive moments.';
      case MoodType.sad:
        return 'You\'ve been going through some tough times. ${mapping?.emoji} Remember, this too shall pass.';
      case MoodType.anxious:
        return 'You\'ve been feeling anxious. ${mapping?.emoji} Try some breathing exercises and mindfulness.';
      case MoodType.calm:
        return 'You\'ve been in a peaceful state. ${mapping?.emoji} This balance is wonderful for your wellbeing.';
      case MoodType.motivated:
        return 'You\'re feeling driven and energized! ${mapping?.emoji} Channel this energy into your goals.';
      case MoodType.grateful:
        return 'Your gratitude is shining through. ${mapping?.emoji} This positive outlook is powerful.';
      default:
        return 'Your emotional journey is unique. Keep tracking to understand your patterns better.';
    }
  }

  // Helper methods
  bool get hasMoodData => moodHistory.isNotEmpty;
  
  MoodEntry? get lastMoodEntry => moodHistory.isNotEmpty ? moodHistory.first : null;
  
  bool get hasFilteredQuotes => moodFilteredQuotes.isNotEmpty;
  
  String getCurrentMoodDescription() {
    if (currentMood == null) return 'No mood selected';
    
    final mapping = MoodQuoteMapping.getMappingForMood(currentMood!);
    return mapping?.description ?? currentMood.toString().split('.').last;
  }

  List<String> getCurrentMoodTags() {
    if (currentMood == null) return [];
    return MoodQuoteMapping.getQuoteTagsForMood(currentMood!);
  }

  // Clear current mood selection
  void clearMoodSelection() {
    currentMood = null;
    currentIntensity = null;
    moodFilteredQuotes.clear();
    
    // Reset to original quotes
    DataRepository().resetToOriginalPhrasersList();
    
    print('Mood selection cleared');
    update();
  }

  // Update quotes list with mood-filtered quotes
  void applyMoodFilterToQuotes() {
    if (hasFilteredQuotes) {
      DataRepository().updateCurrentPhrasersList(moodFilteredQuotes);
    }
  }
}