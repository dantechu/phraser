import 'package:floor/floor.dart';

import '../../util/constant_strings.dart';

enum HabitFrequency { daily, weekly, monthly }

enum HabitCategory { 
  mindfulness, 
  fitness, 
  productivity, 
  relationships, 
  learning, 
  creativity, 
  health, 
  spirituality 
}

enum HabitDifficulty { beginner, intermediate, advanced }

@Entity(tableName: ConstantStrings.kHabitsTableName)
class Habit {
  Habit({
    required this.habitId,
    required this.name,
    required this.description,
    required this.category,
    required this.frequency,
    required this.difficulty,
    required this.targetValue,
    required this.unit,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.iconPath,
    this.colorHex,
    this.motivationalQuote,
    this.tags,
  });

  @primaryKey
  late final String habitId;
  late final String name;
  late final String description;
  late final String category; // HabitCategory enum as string
  late final String frequency; // HabitFrequency enum as string
  late final String difficulty; // HabitDifficulty enum as string
  late final int targetValue; // e.g., 10 pushups, 30 minutes reading
  late final String unit; // e.g., "minutes", "times", "pages"
  late final bool isActive;
  late final String createdAt;
  late final String updatedAt;
  late final String? iconPath;
  late final String? colorHex;
  late final String? motivationalQuote;
  late final String? tags; // comma-separated tags for quotes

  Habit.fromJson(Map<String, dynamic> json) {
    habitId = json['habit_id'];
    name = json['name'];
    description = json['description'];
    category = json['category'];
    frequency = json['frequency'];
    difficulty = json['difficulty'];
    targetValue = json['target_value'];
    unit = json['unit'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    iconPath = json['icon_path'];
    colorHex = json['color_hex'];
    motivationalQuote = json['motivational_quote'];
    tags = json['tags'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['habit_id'] = habitId;
    data['name'] = name;
    data['description'] = description;
    data['category'] = category;
    data['frequency'] = frequency;
    data['difficulty'] = difficulty;
    data['target_value'] = targetValue;
    data['unit'] = unit;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['icon_path'] = iconPath;
    data['color_hex'] = colorHex;
    data['motivational_quote'] = motivationalQuote;
    data['tags'] = tags;
    return data;
  }

  HabitCategory get categoryEnum => HabitCategory.values.firstWhere(
    (e) => e.toString().split('.').last == category,
    orElse: () => HabitCategory.mindfulness,
  );

  HabitFrequency get frequencyEnum => HabitFrequency.values.firstWhere(
    (e) => e.toString().split('.').last == frequency,
    orElse: () => HabitFrequency.daily,
  );

  HabitDifficulty get difficultyEnum => HabitDifficulty.values.firstWhere(
    (e) => e.toString().split('.').last == difficulty,
    orElse: () => HabitDifficulty.beginner,
  );
}

class HabitTemplate {
  final String name;
  final String description;
  final HabitCategory category;
  final HabitFrequency frequency;
  final HabitDifficulty difficulty;
  final int targetValue;
  final String unit;
  final String iconPath;
  final String colorHex;
  final String motivationalQuote;
  final List<String> relatedTags;

  HabitTemplate({
    required this.name,
    required this.description,
    required this.category,
    required this.frequency,
    required this.difficulty,
    required this.targetValue,
    required this.unit,
    required this.iconPath,
    required this.colorHex,
    required this.motivationalQuote,
    required this.relatedTags,
  });

  static List<HabitTemplate> getDefaultTemplates() {
    return [
      HabitTemplate(
        name: "Daily Meditation",
        description: "Practice mindfulness and find inner peace through daily meditation",
        category: HabitCategory.mindfulness,
        frequency: HabitFrequency.daily,
        difficulty: HabitDifficulty.beginner,
        targetValue: 10,
        unit: "minutes",
        iconPath: "meditation.png",
        colorHex: "#4A90E2",
        motivationalQuote: "Peace comes from within. Do not seek it without.",
        relatedTags: ["mindfulness", "peace", "inner_strength", "calm"],
      ),
      HabitTemplate(
        name: "Morning Exercise",
        description: "Start your day with energizing physical activity",
        category: HabitCategory.fitness,
        frequency: HabitFrequency.daily,
        difficulty: HabitDifficulty.beginner,
        targetValue: 30,
        unit: "minutes",
        iconPath: "exercise.png",
        colorHex: "#F5A623",
        motivationalQuote: "Your body can stand almost anything. It's your mind you have to convince.",
        relatedTags: ["fitness", "energy", "strength", "morning"],
      ),
      HabitTemplate(
        name: "Gratitude Journal",
        description: "Write down three things you're grateful for each day",
        category: HabitCategory.mindfulness,
        frequency: HabitFrequency.daily,
        difficulty: HabitDifficulty.beginner,
        targetValue: 3,
        unit: "items",
        iconPath: "journal.png",
        colorHex: "#7ED321",
        motivationalQuote: "Gratitude turns what we have into enough.",
        relatedTags: ["gratitude", "thankfulness", "positive_thinking", "reflection"],
      ),
      HabitTemplate(
        name: "Read Books",
        description: "Expand your knowledge through daily reading",
        category: HabitCategory.learning,
        frequency: HabitFrequency.daily,
        difficulty: HabitDifficulty.intermediate,
        targetValue: 20,
        unit: "pages",
        iconPath: "book.png",
        colorHex: "#9013FE",
        motivationalQuote: "Reading is to the mind what exercise is to the body.",
        relatedTags: ["learning", "knowledge", "growth", "wisdom"],
      ),
      HabitTemplate(
        name: "Creative Writing",
        description: "Express your thoughts and ideas through writing",
        category: HabitCategory.creativity,
        frequency: HabitFrequency.daily,
        difficulty: HabitDifficulty.intermediate,
        targetValue: 15,
        unit: "minutes",
        iconPath: "writing.png",
        colorHex: "#FF6B6B",
        motivationalQuote: "Creativity takes courage.",
        relatedTags: ["creativity", "expression", "writing", "imagination"],
      ),
      HabitTemplate(
        name: "Deep Work Focus",
        description: "Practice focused work without distractions",
        category: HabitCategory.productivity,
        frequency: HabitFrequency.daily,
        difficulty: HabitDifficulty.advanced,
        targetValue: 90,
        unit: "minutes",
        iconPath: "focus.png",
        colorHex: "#50E3C2",
        motivationalQuote: "Focus is a matter of deciding what things you're not going to do.",
        relatedTags: ["focus", "productivity", "deep_work", "concentration"],
      ),
    ];
  }
}