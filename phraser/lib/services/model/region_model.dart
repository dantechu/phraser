import 'package:floor/floor.dart';

import '../../util/constant_strings.dart';

enum RegionType { asia, eastern, western, universal }

enum CulturalContext {
  collectivist,
  individualist,
  spiritual,
  pragmatic,
  philosophical,
  modern,
  traditional
}

@Entity(tableName: ConstantStrings.kRegionPreferenceTableName)
class RegionPreference {
  RegionPreference({
    required this.preferenceId,
    required this.userId,
    required this.primaryRegion,
    required this.secondaryRegions,
    required this.culturalContexts,
    required this.languagePreferences,
    required this.createdAt,
    required this.updatedAt,
    this.timeZone,
    this.country,
    this.customPreferences,
  });

  @primaryKey
  late final String preferenceId;
  late final String userId;
  late final String primaryRegion; // RegionType enum as string
  late final String secondaryRegions; // Comma-separated RegionType values
  late final String culturalContexts; // Comma-separated CulturalContext values
  late final String languagePreferences; // Comma-separated language codes
  late final String createdAt;
  late final String updatedAt;
  late final String? timeZone;
  late final String? country;
  late final String? customPreferences; // JSON string for custom settings

  RegionPreference.fromJson(Map<String, dynamic> json) {
    preferenceId = json['preference_id'];
    userId = json['user_id'];
    primaryRegion = json['primary_region'];
    secondaryRegions = json['secondary_regions'];
    culturalContexts = json['cultural_contexts'];
    languagePreferences = json['language_preferences'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    timeZone = json['time_zone'];
    country = json['country'];
    customPreferences = json['custom_preferences'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['preference_id'] = preferenceId;
    data['user_id'] = userId;
    data['primary_region'] = primaryRegion;
    data['secondary_regions'] = secondaryRegions;
    data['cultural_contexts'] = culturalContexts;
    data['language_preferences'] = languagePreferences;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['time_zone'] = timeZone;
    data['country'] = country;
    data['custom_preferences'] = customPreferences;
    return data;
  }

  RegionType get primaryRegionEnum => RegionType.values.firstWhere(
    (e) => e.toString().split('.').last == primaryRegion,
    orElse: () => RegionType.universal,
  );

  List<RegionType> get secondaryRegionEnums => secondaryRegions
      .split(',')
      .where((s) => s.isNotEmpty)
      .map((s) => RegionType.values.firstWhere(
            (e) => e.toString().split('.').last == s.trim(),
            orElse: () => RegionType.universal,
          ))
      .toList();

  List<CulturalContext> get culturalContextEnums => culturalContexts
      .split(',')
      .where((s) => s.isNotEmpty)
      .map((s) => CulturalContext.values.firstWhere(
            (e) => e.toString().split('.').last == s.trim(),
            orElse: () => CulturalContext.modern,
          ))
      .toList();
}

class RegionalQuoteMapping {
  final RegionType region;
  final String name;
  final String description;
  final List<String> quoteTags;
  final List<String> philosophicalTraditions;
  final List<String> culturalValues;
  final String flagEmoji;
  final String colorHex;
  final List<String> sampleAuthors;
  final List<String> wisdomTraditions;

  RegionalQuoteMapping({
    required this.region,
    required this.name,
    required this.description,
    required this.quoteTags,
    required this.philosophicalTraditions,
    required this.culturalValues,
    required this.flagEmoji,
    required this.colorHex,
    required this.sampleAuthors,
    required this.wisdomTraditions,
  });

  static List<RegionalQuoteMapping> getRegionalMappings() {
    return [
      RegionalQuoteMapping(
        region: RegionType.asia,
        name: "Asian Wisdom",
        description: "Ancient wisdom from across Asia emphasizing harmony, balance, and mindfulness",
        quoteTags: [
          "harmony", "balance", "mindfulness", "wisdom", "meditation",
          "zen", "tao", "karma", "dharma", "inner_peace", "patience",
          "compassion", "unity", "simplicity", "nature", "ancestor_wisdom"
        ],
        philosophicalTraditions: [
          "Buddhism", "Taoism", "Confucianism", "Hinduism", "Zen",
          "Shintoism", "Sufism", "Vedanta", "Chan"
        ],
        culturalValues: [
          "Respect for elders", "Harmony with nature", "Family unity",
          "Mindful living", "Spiritual growth", "Community bonds",
          "Inner cultivation", "Humility", "Patience"
        ],
        flagEmoji: "🏯",
        colorHex: "#FF6B35",
        sampleAuthors: [
          "Lao Tzu", "Buddha", "Confucius", "Rumi", "Hafez",
          "Tagore", "Basho", "Gandhi"
        ],
        wisdomTraditions: [
          "Tea ceremony wisdom", "Martial arts philosophy",
          "Garden meditation", "Calligraphy mindfulness",
          "Seasonal awareness", "Ancestral respect"
        ],
      ),
      RegionalQuoteMapping(
        region: RegionType.eastern,
        name: "Eastern Philosophy",
        description: "Deep philosophical insights from Eastern European and Middle Eastern traditions",
        quoteTags: [
          "philosophy", "depth", "contemplation", "truth", "reality",
          "existence", "meaning", "spirituality", "mysticism", "soul",
          "consciousness", "divine", "unity", "transcendence", "wisdom"
        ],
        philosophicalTraditions: [
          "Orthodox Christianity", "Islamic Philosophy", "Kabbalah",
          "Gnostic tradition", "Slavic wisdom", "Sufi mysticism",
          "Neo-Platonism", "Christian mysticism"
        ],
        culturalValues: [
          "Deep contemplation", "Spiritual seeking", "Community bonds",
          "Tradition respect", "Philosophical inquiry", "Sacred art",
          "Mystical experience", "Divine connection"
        ],
        flagEmoji: "⛪",
        colorHex: "#8E44AD",
        sampleAuthors: [
          "Dostoyevsky", "Tolstoy", "Rumi", "Ibn Arabi", "Maimonides",
          "Plotinus", "John of the Cross", "Meister Eckhart"
        ],
        wisdomTraditions: [
          "Hesychasm", "Sufi whirling", "Icon meditation",
          "Sacred geometry", "Liturgical wisdom", "Desert fathers"
        ],
      ),
      RegionalQuoteMapping(
        region: RegionType.western,
        name: "Western Thought",
        description: "Rational, individualistic wisdom emphasizing progress, achievement, and personal growth",
        quoteTags: [
          "achievement", "progress", "individual", "success", "innovation",
          "logic", "reason", "freedom", "rights", "potential", "growth",
          "excellence", "leadership", "courage", "determination", "vision"
        ],
        philosophicalTraditions: [
          "Stoicism", "Existentialism", "Humanism", "Pragmatism",
          "Enlightenment", "Scientific rationalism", "Liberal philosophy",
          "Positive psychology", "Self-actualization"
        ],
        culturalValues: [
          "Individual achievement", "Personal freedom", "Innovation",
          "Scientific progress", "Rational thinking", "Self-improvement",
          "Leadership", "Entrepreneurship", "Excellence"
        ],
        flagEmoji: "🏛️",
        colorHex: "#3498DB",
        sampleAuthors: [
          "Marcus Aurelius", "Shakespeare", "Ralph Waldo Emerson",
          "Viktor Frankl", "Steve Jobs", "Maya Angelou", "Winston Churchill"
        ],
        wisdomTraditions: [
          "Socratic questioning", "Stoic practices", "Renaissance humanism",
          "Scientific method", "Democratic ideals", "Artistic expression"
        ],
      ),
      RegionalQuoteMapping(
        region: RegionType.universal,
        name: "Universal Wisdom",
        description: "Timeless truths that transcend cultural and regional boundaries",
        quoteTags: [
          "universal", "human", "love", "compassion", "kindness",
          "truth", "beauty", "goodness", "unity", "connection",
          "growth", "healing", "hope", "faith", "courage", "peace"
        ],
        philosophicalTraditions: [
          "Perennial philosophy", "Universal ethics", "Human rights",
          "Environmental wisdom", "Global consciousness",
          "Interfaith dialogue", "Humanitarian values"
        ],
        culturalValues: [
          "Human dignity", "Compassion for all", "Environmental care",
          "Global cooperation", "Peace building", "Shared humanity",
          "Universal love", "Collective wisdom"
        ],
        flagEmoji: "🌍",
        colorHex: "#27AE60",
        sampleAuthors: [
          "Mother Teresa", "Nelson Mandela", "Dalai Lama", "Martin Luther King Jr.",
          "Thich Nhat Hanh", "Paulo Coelho", "Carl Jung"
        ],
        wisdomTraditions: [
          "Universal declaration of human rights", "Environmental ethics",
          "Interfaith wisdom", "Global peace movements",
          "Humanitarian principles", "Collective consciousness"
        ],
      ),
    ];
  }

  static RegionalQuoteMapping? getMappingForRegion(RegionType region) {
    return getRegionalMappings().firstWhere(
      (mapping) => mapping.region == region,
    );
  }

  static List<String> getQuoteTagsForRegion(RegionType region) {
    final mapping = getMappingForRegion(region);
    return mapping?.quoteTags ?? [];
  }

  static List<String> getAllRegionalTags() {
    return getRegionalMappings()
        .expand((mapping) => mapping.quoteTags)
        .toSet()
        .toList();
  }
}