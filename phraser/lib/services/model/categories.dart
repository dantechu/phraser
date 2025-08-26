
import 'package:floor/floor.dart';
import 'package:phraser/util/constant_strings.dart';

@Entity(tableName: ConstantStrings.kCategoriesTableName)
class Categories {
  Categories({
    required this.categoryId,
    required this.categoryName,
    required this.categorySection,
    required this.categoryType,
    required this.categoryImage,
    required this.totalPhraser,
    this.isSelected,
  });

  @primaryKey
  late final String categoryId;
  late final String categoryName;
  late final String categorySection;
  late final String categoryType;
  late final String categoryImage;
  late final String totalPhraser;
  bool? isSelected = false;

  Categories.fromJson(Map<String, dynamic> json){
    categoryId = json['category_id'] ?? 10;
    categoryName = json['category_name'] ?? '';
    categorySection = json['category_section'] ?? '';
    categoryType = json['category_type'] ?? '';
    categoryImage = json['category_image'] ?? '';
    totalPhraser = json['total_phraser'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['category_id'] = categoryId;
    _data['category_name'] = categoryName;
    _data['category_section'] = categorySection;
    _data['category_type'] = categoryType;
    _data['category_image'] = categoryImage;
    _data['total_phraser'] = totalPhraser;
    return _data;
  }
}