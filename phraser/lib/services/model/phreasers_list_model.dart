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

  Phraser.fromJson(Map<String, dynamic> json){
    phraserId = json['phraser_id'];
    tags = json['tags'];
    quote = json['quote'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categorySection = json['category_section'];
    categoryType = json['category_type'];
    lastUpdate = json['last_update'];
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
    return _data;
  }
}