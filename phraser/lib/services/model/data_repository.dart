
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/services/model/category_sections.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';

class DataRepository {
  static final DataRepository _singleton =  DataRepository._internal();

  factory DataRepository() {
    return _singleton;
  }

  DataRepository._internal();


  List<Categories> categoriesList = [];
  List<CategorySections> sectionList = [];
  List<Phraser> currentPhrasersList = [];




}