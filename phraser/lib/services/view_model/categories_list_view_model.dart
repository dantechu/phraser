
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:phraser/floor_db/current_phraser_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';

import '../../floor_db/categories_dao.dart';
import '../../floor_db/database.dart';
import '../../floor_db/section_dao.dart';
import '../../util/constant_strings.dart';
import '../../util/constant_urls.dart';
import '../../util/preferences.dart';
import '../../util/utils.dart';
import '../model/categories.dart';
import '../model/categories_list_model.dart';
import '../model/category_sections.dart';
import '../model/data_repository.dart';
import '../model/section_list.dart';

class CategoriesListViewModel extends GetxController {

  bool isCategoriesLoading = false;
  List<CategorySections> currentSectionList = [];
  List<Categories> currentCategoriesList = [];



  void updateLoadingState(bool state) {
    isCategoriesLoading = state;
    update();
  }

  Future checkForData() async{
    testPrint('checkForData()');
    final database = FloorDB.instance.floorDatabase;
    if(Preferences.instance.isCategoriesPresent){
      testPrint('Categories data already present in internal database');
      CategoriesDAO categoriesDAO = database.categoriesDAO;
      categoriesDAO.getAllCategories().then((categoriesList) {
        DataRepository().categoriesList = categoriesList;
        currentCategoriesList = categoriesList;
        testPrint('categories list data inserted into data_repository with length: ${currentCategoriesList.length}');
        updateLoadingState(false);
      });
    }else {
      getCategories();
      testPrint('Categories data not present in internal database');

    }

    if(Preferences.instance.isCategoriesPresent){
      testPrint('Section list data already present in internal database');
      SectionDAO sectionDAO = database.sectionDAO;
      sectionDAO.getAllSection().then((sectionList) {
        DataRepository().sectionList = sectionList;
        currentSectionList = sectionList;
        testPrint('section list data inserted into data_repository with length: ${currentSectionList.length}');
        updateLoadingState(false);
      });
    }else {
      getSectionsList();
      testPrint('Section list data not present in internal database');
    }

  }

  void getCategories() async{
    try{
      var response = await Dio().get(ConstantURls.kGetCategories);
      if (response.statusCode == 200) {
        CategoriesListModel categoriesListModel = CategoriesListModel.fromJson(response.data);
        testPrint('categories length: ${categoriesListModel.categories.length}');
        insertCategoriesToFloorDB(categoriesListModel.categories);

        for(final data in categoriesListModel.categories) {
          getPhrasersByCategory(data.categoryId.toString());
        }

      } else {
        throw Exception('Failed to load getCategories() data!');
      }
    } catch(e){
      testPrint('getCategories Exception: $e');
    }
  }
  void getSectionsList() async{
    try{
      var response = await Dio().get(ConstantURls.kGetSections);
      if (response.statusCode == 200) {
        SectionList sectionList = SectionList.fromJson(response.data);
        testPrint('Sections length: ${sectionList.categorySections.length}');
        insertSectionsToFloorDB(sectionList.categorySections);
        updateLoadingState(false);
      } else {
        throw Exception('Failed to load getSectionsList() data!');
      }
    } catch(e){
      testPrint('getSectionsList() Exception: $e');
    }
  }


  void getPhrasersByCategory(String id) async{
    try{
      var response = await Dio().get(ConstantURls.kGetPhrasersByCategory+'$id');
      if (response.statusCode == 200) {
        testPrint('single category list quotes: ${response.statusCode}');
        PhrasersListModel listModel = PhrasersListModel.fromJson(response.data);

        insertPhrasersToFloorDB(listModel.phraser);

      } else {
        throw Exception('Failed to load getPhrasersByCategory() data!');
      }
    } catch(e){
      testPrint('getPhrasersByCategory() Exception: $e');
    }
  }

  void insertPhrasersToFloorDB(List<Phraser> listModel) async {
    try{

      final database = FloorDB.instance.floorDatabase;

      PhrasersDAO phrasersDAO = database.phraserDAO;
      phrasersDAO.insertAllPhrasers(listModel);
      testPrint('${listModel[0].categoryName} wit id ${listModel[0].categoryId} list data inserted to floor db ');
      if(listModel[0].categoryName.toLowerCase().contains('self respect')) {
        if(Preferences.instance.isFirstOpen) {
          final database = FloorDB.instance.floorDatabase;
          CurrentPhrasersDAO currentPhraserDAO = database.currentPhraserDAO;
          await  currentPhraserDAO.insertAllCurrentPhrasers(listModel)
              .then((value) {
            testPrint('first time current phrasers saved into db');
          });
          DataRepository().currentPhrasersList = listModel;
          debugPrint('---> Personal growth category set for first time');
        }
      }
      Preferences.instance.isCategoriesPresent = true;
      // });
    }catch(e) {
      throw Exception('Exception in insertPhrasersToFloorDB() : $e');
    }
  }

  void insertSectionsToFloorDB(List<CategorySections> sectionList) async {
    try{

      final database = FloorDB.instance.floorDatabase;

      SectionDAO sectionDAO = database.sectionDAO;
      sectionDAO.insertAllSections(sectionList);
      testPrint('sections list data inserted to floor db');
      Preferences.instance.isCategoriesPresent = true;
      sectionDAO.getAllSection().then((sectionList) {
        DataRepository().sectionList = sectionList;
        currentSectionList = sectionList;
        update();
        testPrint('Total sections in floor db: ${sectionList.length}');
      });
    }catch(e) {
      throw Exception('Exception in insertSectionsToFloorDB() : $e');
    }
  }


  void insertCategoriesToFloorDB(List<Categories> categoriesList) async {
    try{

      final database = FloorDB.instance.floorDatabase;

      CategoriesDAO categoriesDAO = database.categoriesDAO;
      categoriesDAO.insertAllCategories(categoriesList);
      testPrint('categories list data inserted to floor db');
      Preferences.instance.isCategoriesPresent = true;
      categoriesDAO.getAllCategories().then((categoriesList) {
        DataRepository().categoriesList = categoriesList;
        currentCategoriesList = categoriesList;
        update();
        testPrint('Total categories in floor db: ${categoriesList.length}');
      });
    }catch(e) {
      throw Exception('Exception in insertCategoriesToFloorDB() : $e');
    }
  }

}