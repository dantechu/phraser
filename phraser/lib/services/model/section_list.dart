import 'category_sections.dart';

class SectionList {
  SectionList({
    required this.status,
    required this.categorySections,
  });
  late final String status;
  late final List<CategorySections> categorySections;

  SectionList.fromJson(Map<String, dynamic> json){
    status = json['status'];
    categorySections = List.from(json['category_sections']).map((e)=>CategorySections.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['category_sections'] = categorySections.map((e)=>e.toJson()).toList();
    return _data;
  }
}

