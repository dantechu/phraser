import 'package:phraser/services/model/categories.dart';

class CategoriesListModel {
  CategoriesListModel({
    required this.status,
    required this.count,
    required this.categories,
  });
  late final String status;
  late final int count;
  late final List<Categories> categories;

  CategoriesListModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    count = json['count'];
    categories = List.from(json['categories']).map((e)=>Categories.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['count'] = count;
    _data['categories'] = categories.map((e)=>e.toJson()).toList();
    return _data;
  }
}

