
import 'package:floor/floor.dart';
import 'package:phraser/util/constant_strings.dart';

@Entity(tableName: ConstantStrings.kSectionTableName)
class CategorySections {
  CategorySections({
    required this.id,
    required this.name,
  });
  @primaryKey
  late final String id;
  late final String name;

  CategorySections.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}