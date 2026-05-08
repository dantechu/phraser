import 'package:floor/floor.dart';
import '../../util/constant_strings.dart';
import 'mood_api_model.dart';

@Entity(tableName: ConstantStrings.kMoodsTableName)
class MoodEntity {
  @PrimaryKey()
  final String moodId;
  final String moodTitle;
  final String moodIcon;
  final String totalPhrasers;

  MoodEntity({
    required this.moodId,
    required this.moodTitle,
    required this.moodIcon,
    required this.totalPhrasers,
  });

  // Convert from API model to entity
  factory MoodEntity.fromMoodItem(MoodItem item) {
    return MoodEntity(
      moodId: item.moodId,
      moodTitle: item.moodTitle,
      moodIcon: item.moodIcon,
      totalPhrasers: item.totalPhrasers,
    );
  }

  // Convert from entity to API model
  MoodItem toMoodItem() {
    return MoodItem(
      moodId: moodId,
      moodTitle: moodTitle,
      moodIcon: moodIcon,
      totalPhrasers: totalPhrasers,
    );
  }

  factory MoodEntity.fromJson(Map<String, dynamic> json) {
    return MoodEntity(
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
