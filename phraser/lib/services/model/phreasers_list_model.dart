import 'package:floor/floor.dart';

import '../../util/constant_strings.dart';

class PhrasersListModel {
  PhrasersListModel({
    required this.status,
    required this.count,
    required this.countTotal,
    required this.pages,
    required this.phraser,
  });
  late final String status;
  late final int count;
  late final String countTotal;
  late final int pages;
  late final List<Phraser> phraser;

  PhrasersListModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    count = json['count'];
    countTotal = json['count_total'];
    pages = json['pages'];
    phraser = List.from(json['posts']).map((e)=>Phraser.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['count'] = count;
    _data['count_total'] = countTotal;
    _data['pages'] = pages;
    _data['posts'] = phraser.map((e)=>e.toJson()).toList();
    return _data;
  }
}

@Entity(tableName: ConstantStrings.kPhrasersTableName)
class Phraser {
  Phraser({
    required this.phraserId,
    required this.tags,
    required this.quote,
    required this.categoryId,
    required this.categoryName,
    required this.categorySection,
    required this.categoryType,
    required this.lastUpdate,
    this.moodTags,
    this.regionalTags,
    this.habitTags,
    this.culturalContext,
    this.wisdomTradition,
    this.author,
    this.region,
    this.emotionalTone,
    this.intensityLevel,
  });

  @primaryKey
  late final String phraserId;
  late final String tags;
  late final String quote;
  late final String categoryId;
  late final String categoryName;
  late final String categorySection;
  late final String categoryType;
  late final String lastUpdate;
  
  // New fields for enhanced quote categorization
  late final String? moodTags; // Comma-separated mood-related tags (happy, sad, calm, motivated, etc.)
  late final String? regionalTags; // Comma-separated regional classification tags
  late final String? habitTags; // Comma-separated habit-related tags (fitness, meditation, learning, etc.)
  late final String? culturalContext; // Cultural context (collectivist, individualist, spiritual, etc.)
  late final String? wisdomTradition; // Wisdom tradition (buddhism, stoicism, etc.)
  late final String? author; // Quote author if known
  late final String? region; // Primary region (asia, eastern, western, universal)
  late final String? emotionalTone; // Emotional tone (uplifting, calming, motivating, etc.)
  late final int? intensityLevel; // Intensity level 1-5 for matching user's current energy

  Phraser.fromJson(Map<String, dynamic> json){
    phraserId = json['phraser_id'];
    tags = json['tags'];
    quote = json['quote'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categorySection = json['category_section'];
    categoryType = json['category_type'];
    lastUpdate = json['last_update'];
    moodTags = json['mood_tags'];
    regionalTags = json['regional_tags'];
    habitTags = json['habit_tags'];
    culturalContext = json['cultural_context'];
    wisdomTradition = json['wisdom_tradition'];
    author = json['author'];
    region = json['region'];
    emotionalTone = json['emotional_tone'];
    intensityLevel = json['intensity_level'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['phraser_id'] = phraserId;
    _data['tags'] = tags;
    _data['quote'] = quote;
    _data['category_id'] = categoryId;
    _data['category_name'] = categoryName;
    _data['category_section'] = categorySection;
    _data['category_type'] = categoryType;
    _data['last_update'] = lastUpdate;
    _data['mood_tags'] = moodTags;
    _data['regional_tags'] = regionalTags;
    _data['habit_tags'] = habitTags;
    _data['cultural_context'] = culturalContext;
    _data['wisdom_tradition'] = wisdomTradition;
    _data['author'] = author;
    _data['region'] = region;
    _data['emotional_tone'] = emotionalTone;
    _data['intensity_level'] = intensityLevel;
    return _data;
  }

  // Helper methods for enhanced quote filtering
  List<String> get moodTagsList => moodTags?.split(',').map((e) => e.trim()).toList() ?? [];
  List<String> get regionalTagsList => regionalTags?.split(',').map((e) => e.trim()).toList() ?? [];
  List<String> get habitTagsList => habitTags?.split(',').map((e) => e.trim()).toList() ?? [];
  
  bool matchesMood(String targetMood) {
    return moodTagsList.contains(targetMood.toLowerCase());
  }
  
  bool matchesRegion(String targetRegion) {
    return region == targetRegion || regionalTagsList.contains(targetRegion.toLowerCase());
  }
  
  bool matchesHabit(String habitCategory) {
    return habitTagsList.contains(habitCategory.toLowerCase());
  }
  
  bool matchesIntensity(int userIntensity, {int tolerance = 1}) {
    if (intensityLevel == null) return true; // Match any if not specified
    return (intensityLevel! - userIntensity).abs() <= tolerance;
  }
}