
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

  // Store original phrasers list for filtering purposes
  List<Phraser> _originalPhrasersList = [];

  void updateCurrentPhrasersList(List<Phraser> newList) {
    // Save original list if not already saved
    if (_originalPhrasersList.isEmpty && currentPhrasersList.isNotEmpty) {
      _originalPhrasersList = List.from(currentPhrasersList);
    }
    
    currentPhrasersList = newList;
  }

  void resetToOriginalPhrasersList() {
    if (_originalPhrasersList.isNotEmpty) {
      currentPhrasersList = List.from(_originalPhrasersList);
    }
  }

  void saveOriginalPhrasersList() {
    _originalPhrasersList = List.from(currentPhrasersList);
  }




}