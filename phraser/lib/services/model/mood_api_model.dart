class MoodApiModel {
  final String status;
  final int count;
  final List<MoodItem> moods;

  MoodApiModel({
    required this.status,
    required this.count,
    required this.moods,
  });

  factory MoodApiModel.fromJson(Map<String, dynamic> json) {
    return MoodApiModel(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      moods: (json['moods'] as List<dynamic>?)
              ?.map((e) => MoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'moods': moods.map((e) => e.toJson()).toList(),
    };
  }
}

class MoodItem {
  final String moodId;
  final String moodTitle;
  final String moodIcon;
  final String totalPhrasers;

  MoodItem({
    required this.moodId,
    required this.moodTitle,
    required this.moodIcon,
    required this.totalPhrasers,
  });

  factory MoodItem.fromJson(Map<String, dynamic> json) {
    return MoodItem(
      moodId: json['mood_id']?.toString() ?? '',
      moodTitle: json['mood_title']?.toString() ?? '',
      moodIcon: json['mood_icon']?.toString() ?? '😊',
      totalPhrasers: json['total_phrasers']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood_id': moodId,
      'mood_title': moodTitle,
      'mood_icon': moodIcon,
      'total_phrasers': totalPhrasers,
    };
  }
}
