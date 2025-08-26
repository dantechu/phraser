class SavedCategoryListModel {
  SavedCategoryListModel({
    required this.savedList,
  });
  late final List<SavedList> savedList;

  SavedCategoryListModel.fromJson(Map<String, dynamic> json){
    savedList = List.from(json['saved_list']).map((e)=>SavedList.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['saved_list'] = savedList.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class SavedList {
  SavedList({
    required this.id,
    required this.name,
  });
  late final String id;
  late final String name;

  SavedList.fromJson(Map<String, dynamic> json){
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