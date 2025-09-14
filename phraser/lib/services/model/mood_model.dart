import 'package:floor/floor.dart';

import '../../util/constant_strings.dart';

enum MoodType {
  happy,
  sad,
  anxious,
  calm,
  motivated,
  tired,
  stressed,
  confident,
  grateful,
  lonely,
  excited,
  frustrated,
  peaceful,
  overwhelmed,
  inspired
}

enum MoodIntensity { low, medium, high }

@Entity(tableName: ConstantStrings.kMoodTrackingTableName)
class MoodEntry {
  MoodEntry({
    required this.moodId,
    required this.mood,
    required this.intensity,
    required this.date,
    required this.timestamp,
    this.notes,
    this.triggers,
    this.activities,
  });

  @primaryKey
  late final String moodId;
  late final String mood; // MoodType enum as string
  late final String intensity; // MoodIntensity enum as string
  late final String date; // Format: YYYY-MM-DD
  late final String timestamp; // ISO timestamp
  late final String? notes;
  late final String? triggers; // Comma-separated list
  late final String? activities; // What user was doing

  MoodEntry.fromJson(Map<String, dynamic> json) {
    moodId = json['mood_id'];
    mood = json['mood'];
    intensity = json['intensity'];
    date = json['date'];
    timestamp = json['timestamp'];
    notes = json['notes'];
    triggers = json['triggers'];
    activities = json['activities'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['mood_id'] = moodId;
    data['mood'] = mood;
    data['intensity'] = intensity;
    data['date'] = date;
    data['timestamp'] = timestamp;
    data['notes'] = notes;
    data['triggers'] = triggers;
    data['activities'] = activities;
    return data;
  }

  MoodType get moodEnum => MoodType.values.firstWhere(
    (e) => e.toString().split('.').last == mood,
    orElse: () => MoodType.calm,
  );

  MoodIntensity get intensityEnum => MoodIntensity.values.firstWhere(
    (e) => e.toString().split('.').last == intensity,
    orElse: () => MoodIntensity.medium,
  );
}

class MoodQuoteMapping {
  final MoodType mood;
  final List<String> quoteTags;
  final String description;
  final String emoji;
  final String colorHex;

  MoodQuoteMapping({
    required this.mood,
    required this.quoteTags,
    required this.description,
    required this.emoji,
    required this.colorHex,
  });

  static List<MoodQuoteMapping> getMoodMappings() {
    return [
      MoodQuoteMapping(
        mood: MoodType.happy,
        quoteTags: ["joy", "happiness", "celebration", "positive", "gratitude"],
        description: "Celebrating life's beautiful moments",
        emoji: "😊",
        colorHex: "#FFD700",
      ),
      MoodQuoteMapping(
        mood: MoodType.sad,
        quoteTags: ["healing", "hope", "comfort", "strength", "resilience"],
        description: "Finding light in difficult times",
        emoji: "💙",
        colorHex: "#4A90E2",
      ),
      MoodQuoteMapping(
        mood: MoodType.anxious,
        quoteTags: ["calm", "peace", "breathing", "present_moment", "mindfulness"],
        description: "Finding peace in the present moment",
        emoji: "🌊",
        colorHex: "#50E3C2",
      ),
      MoodQuoteMapping(
        mood: MoodType.calm,
        quoteTags: ["serenity", "balance", "meditation", "inner_peace", "tranquility"],
        description: "Embracing inner tranquility",
        emoji: "🧘",
        colorHex: "#7ED321",
      ),
      MoodQuoteMapping(
        mood: MoodType.motivated,
        quoteTags: ["motivation", "goals", "achievement", "progress", "determination"],
        description: "Fueling your inner drive",
        emoji: "🚀",
        colorHex: "#F5A623",
      ),
      MoodQuoteMapping(
        mood: MoodType.tired,
        quoteTags: ["rest", "self_care", "energy", "renewal", "gentle"],
        description: "Honoring your need for rest",
        emoji: "😴",
        colorHex: "#9013FE",
      ),
      MoodQuoteMapping(
        mood: MoodType.stressed,
        quoteTags: ["stress_relief", "calm", "perspective", "breathing", "release"],
        description: "Finding relief from life's pressures",
        emoji: "🌪️",
        colorHex: "#FF6B6B",
      ),
      MoodQuoteMapping(
        mood: MoodType.confident,
        quoteTags: ["confidence", "self_belief", "courage", "strength", "power"],
        description: "Embracing your inner strength",
        emoji: "💪",
        colorHex: "#BD10E0",
      ),
      MoodQuoteMapping(
        mood: MoodType.grateful,
        quoteTags: ["gratitude", "thankfulness", "appreciation", "blessings", "abundance"],
        description: "Celebrating life's gifts",
        emoji: "🙏",
        colorHex: "#8E44AD",
      ),
      MoodQuoteMapping(
        mood: MoodType.lonely,
        quoteTags: ["connection", "love", "community", "belonging", "support"],
        description: "Remembering you're never truly alone",
        emoji: "🤗",
        colorHex: "#E67E22",
      ),
      MoodQuoteMapping(
        mood: MoodType.excited,
        quoteTags: ["excitement", "adventure", "possibilities", "energy", "enthusiasm"],
        description: "Channeling your enthusiasm",
        emoji: "🎉",
        colorHex: "#E74C3C",
      ),
      MoodQuoteMapping(
        mood: MoodType.frustrated,
        quoteTags: ["patience", "understanding", "growth", "learning", "perspective"],
        description: "Transforming challenges into growth",
        emoji: "😤",
        colorHex: "#34495E",
      ),
      MoodQuoteMapping(
        mood: MoodType.peaceful,
        quoteTags: ["peace", "harmony", "stillness", "balance", "zen"],
        description: "Basking in life's peaceful moments",
        emoji: "🕊️",
        colorHex: "#16A085",
      ),
      MoodQuoteMapping(
        mood: MoodType.overwhelmed,
        quoteTags: ["simplicity", "focus", "prioritize", "breathe", "one_step"],
        description: "Taking it one step at a time",
        emoji: "🌀",
        colorHex: "#95A5A6",
      ),
      MoodQuoteMapping(
        mood: MoodType.inspired,
        quoteTags: ["inspiration", "creativity", "vision", "dreams", "possibility"],
        description: "Embracing limitless possibilities",
        emoji: "✨",
        colorHex: "#F39C12",
      ),
    ];
  }

  static MoodQuoteMapping? getMappingForMood(MoodType mood) {
    return getMoodMappings().firstWhere(
      (mapping) => mapping.mood == mood,
    );
  }

  static List<String> getQuoteTagsForMood(MoodType mood) {
    final mapping = getMappingForMood(mood);
    return mapping?.quoteTags ?? [];
  }
}