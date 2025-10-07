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
    print('**** phrasers count total: $countTotal');
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
    this.moodsString,
    this.regionsString,
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
  
  // New parameters for enhanced quote categorization
  // Stored as comma-separated strings in database, converted to List<String> when needed
  late final String? moodsString; // Comma-separated mood strings (happy,sad,calm,motivated,etc.)
  late final String? regionsString; // Comma-separated regional strings

  Phraser.fromJson(Map<String, dynamic> json){
    phraserId = json['phraser_id'];
    tags = json['tags'];
    quote = json['quote'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categorySection = json['category_section'];
    categoryType = json['category_type'];
    lastUpdate = json['last_update'];
    
    // Handle both list and string formats for backward compatibility
    if (json['moods'] != null && (json['moods'] as List).isNotEmpty) {
      if (json['moods'] is List) {
        moodsString = (json['moods'] as List).join(',');
      } else {
        moodsString = json['moods'];
      }
    } else {
      moodsString = null;
    }
    
    if (json['regions'] != null && (json['regions'] as List).isNotEmpty) {
      if (json['regions'] is List) {
        regionsString = (json['regions'] as List).join(',');
      } else {
        regionsString = json['regions'];
      }
    } else {
      regionsString = null;
    }
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
    _data['moods'] = moodsString;
    _data['regions'] = regionsString;
    return _data;
  }

  // Helper methods to get lists from comma-separated strings
  List<String>? get moods {
    if (moodsString == null || moodsString!.isEmpty) return null;
    return moodsString!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
  
  List<String>? get regions {
    if (regionsString == null || regionsString!.isEmpty) return null;
    return regionsString!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  // Helper methods for enhanced quote filtering
  bool matchesMood(String targetMood) {
    return moods?.contains(targetMood.toLowerCase()) ?? false;
  }
  
  bool matchesRegion(String targetRegion) {
    return regions?.contains(targetRegion.toLowerCase()) ?? false;
  }
}