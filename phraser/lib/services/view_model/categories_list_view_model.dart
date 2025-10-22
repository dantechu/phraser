
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
      // Check phraser count before calling getCategories
      final database = FloorDB.instance.floorDatabase;
      PhrasersDAO phrasersDAO = database.phraserDAO;
      final allPhrasers = await phrasersDAO.getAllQuotesFromAllCategories();
      if (allPhrasers.length <= 5000) {
        getCategories();
        testPrint('Categories data not present - calling API (phraser count: ${allPhrasers.length})');
      } else {
        testPrint('Skipping getCategories - phraser count exceeds 5000 (current: ${allPhrasers.length})');
        updateLoadingState(false);
      }
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

  Future<void> getCategories() async{
    try{
      // Get the selected region from preferences
      String? selectedRegion = Preferences.instance.selectedRegion;
      String regionParam = '';

      // If region is selected and not empty, add it to the URL
      if (selectedRegion != null && selectedRegion.isNotEmpty) {
        regionParam = '&region=$selectedRegion';
      }

      var response = await Dio().get(ConstantURls.kGetCategories + regionParam);
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

  // Fast initial loading - loads only first category, then loads rest in background
  Future<void> getCategoriesWithPhrasers(Function(String categoryName, int current, int total) onProgress) async{
    try{
      // Get the selected region from preferences
      String? selectedRegion = Preferences.instance.selectedRegion;
      String regionParam = '';

      // If region is selected and not empty, add it to the URL
      if (selectedRegion != null && selectedRegion.isNotEmpty) {
        regionParam = '&region=$selectedRegion';
      }

      var response = await Dio().get(ConstantURls.kGetCategories + regionParam);
      if (response.statusCode == 200) {
        CategoriesListModel categoriesListModel = CategoriesListModel.fromJson(response.data);
        testPrint('categories length: ${categoriesListModel.categories.length}');

        // Insert categories to DB immediately
        await insertCategoriesToFloorDBAsync(categoriesListModel.categories);

        if (categoriesListModel.categories.isEmpty) {
          throw Exception('No categories received from server');
        }

        // Load ONLY the first category immediately for fast startup
        final firstCategory = categoriesListModel.categories.first;
        onProgress(firstCategory.categoryName, 1, categoriesListModel.categories.length);
        await getPhrasersByCategoryAsync(firstCategory.categoryId.toString());

        testPrint('✅ First category loaded: ${firstCategory.categoryName}');

        // Mark that initial data is ready
        Preferences.instance.isInitialDataLoaded = true;

        // Load remaining categories in background (don't await)
        if (categoriesListModel.categories.length > 1) {
          _loadRemainingCategoriesInBackground(
            categoriesListModel.categories.skip(1).toList(),
            onProgress
          );
        }

      } else {
        throw Exception('Failed to load getCategories() data!');
      }
    } catch(e){
      testPrint('getCategories Exception: $e');
      rethrow;
    }
  }

  // Background loading of remaining categories
  void _loadRemainingCategoriesInBackground(
    List<Categories> remainingCategories,
    Function(String categoryName, int current, int total) onProgress
  ) async {
    testPrint('📦 Starting background loading of ${remainingCategories.length} remaining categories');

    final totalCategories = remainingCategories.length + 1; // +1 for the first category already loaded

    for(int i = 0; i < remainingCategories.length; i++) {
      try {
        final category = remainingCategories[i];
        final currentIndex = i + 2; // +2 because first category is already loaded (index 1)

        testPrint('📦 Loading category $currentIndex/$totalCategories: ${category.categoryName}');
        await getPhrasersByCategoryAsync(category.categoryId.toString());

        // Small delay to prevent overwhelming the device
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        testPrint('❌ Error loading category ${remainingCategories[i].categoryName}: $e');
        // Continue loading other categories even if one fails
      }
    }

    testPrint('✅ Background loading completed for all categories');
  }

  // Async version of getPhrasersByCategory for faster loading
  Future<void> getPhrasersByCategoryAsync(String id) async{
    try{
      // Get the selected region from preferences
      String? selectedRegion = Preferences.instance.selectedRegion;
      String regionParam = '';

      // If region is selected and not empty, add it to the URL
      if (selectedRegion != null && selectedRegion.isNotEmpty) {
        regionParam = '&region=$selectedRegion';
      }

      var response = await Dio().get(ConstantURls.kGetPhrasersByCategory+'$id$regionParam');
      if (response.statusCode == 200) {
        PhrasersListModel listModel = PhrasersListModel.fromJson(response.data);
        await insertPhrasersToFloorDBAsync(listModel.phraser);
        print('single category list quotes: ${listModel.phraser.length} for id: $id');
      } else {
        throw Exception('Failed to load getPhrasersByCategory() data!');
      }
    } catch(e){
      testPrint('getPhrasersByCategory() Exception: $e');
      rethrow;
    }
  }

  // Async version for insertPhrasersToFloorDB
  Future<void> insertPhrasersToFloorDBAsync(List<Phraser> listModel) async {
    try{
      final database = FloorDB.instance.floorDatabase;
      PhrasersDAO phrasersDAO = database.phraserDAO;
      await phrasersDAO.insertAllPhrasers(listModel);
      testPrint('${listModel[0].categoryName} wit id ${listModel[0].categoryId} list data inserted to floor db ');

      // On first app start, load first category's quotes
      if(Preferences.instance.isFirstOpen) {
        // Check if this is the first category being loaded (categoryId should be the lowest/first)
        if(listModel.isNotEmpty) {
          final database = FloorDB.instance.floorDatabase;
          final categoriesDAO = database.categoriesDAO;
          final allCategories = await categoriesDAO.getAllCategories();

          // Find the first category by sorting category IDs
          if(allCategories.isNotEmpty) {
            allCategories.sort((a, b) => int.parse(a.categoryId).compareTo(int.parse(b.categoryId)));
            final firstCategoryId = allCategories.first.categoryId;

            // If this is the first category, save it to current phrasers
            if(listModel[0].categoryId == firstCategoryId) {
              CurrentPhrasersDAO currentPhraserDAO = database.currentPhraserDAO;
              await currentPhraserDAO.deleteCurrentPhrasers();
              await currentPhraserDAO.insertAllCurrentPhrasers(listModel);
              testPrint('First app start: ${listModel[0].categoryName} (ID: ${listModel[0].categoryId}) quotes saved to current phrasers');
              DataRepository().currentPhrasersList = listModel;
              DataRepository().addToAllQuotes(listModel);
              Preferences.instance.currentPhraserPosition = 0;
              debugPrint('---> First category loaded with ${listModel.length} quotes');
            }
          }
        }
      }
      Preferences.instance.isCategoriesPresent = true;
    }catch(e) {
      throw Exception('Exception in insertPhrasersToFloorDB() : $e');
    }
  }

  // Async version for insertCategoriesToFloorDB
  Future<void> insertCategoriesToFloorDBAsync(List<Categories> categoriesList) async {
    try{
      final database = FloorDB.instance.floorDatabase;
      CategoriesDAO categoriesDAO = database.categoriesDAO;
      await categoriesDAO.insertAllCategories(categoriesList);
      testPrint('categories list data inserted to floor db');
      Preferences.instance.isCategoriesPresent = true;

      final savedCategories = await categoriesDAO.getAllCategories();
      DataRepository().categoriesList = savedCategories;
      currentCategoriesList = savedCategories;
      update();
      testPrint('Total categories in floor db: ${savedCategories.length}');
    }catch(e) {
      throw Exception('Exception in insertCategoriesToFloorDB() : $e');
    }
  }
  Future<void> getSectionsList() async{
    try{
      // Get the selected region from preferences
      String? selectedRegion = Preferences.instance.selectedRegion;
      String regionParam = '';
      
      // If region is selected and not empty, add it to the URL
      if (selectedRegion != null && selectedRegion.isNotEmpty) {
        regionParam = '&region=$selectedRegion';
      }
      
      var response = await Dio().get(ConstantURls.kGetSections + regionParam);
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


  Future<void> getPhrasersByCategory(String id) async{
    try{
      // Get the selected region from preferences
      String? selectedRegion = Preferences.instance.selectedRegion;
      String regionParam = '';
      
      // If region is selected and not empty, add it to the URL
      if (selectedRegion != null && selectedRegion.isNotEmpty) {
        regionParam = '&region=$selectedRegion';
      }
      
      var response = await Dio().get(ConstantURls.kGetPhrasersByCategory+'$id$regionParam');
      if (response.statusCode == 200) {
        PhrasersListModel listModel = PhrasersListModel.fromJson(response.data);

        insertPhrasersToFloorDB(listModel.phraser);
         print('single category list quotes: ${listModel.phraser.length} for id: $id');
       

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

      // On first app start, load first category's quotes
      if(Preferences.instance.isFirstOpen) {
        // Check if this is the first category being loaded (categoryId should be the lowest/first)
        if(listModel.isNotEmpty) {
          final database = FloorDB.instance.floorDatabase;
          final categoriesDAO = database.categoriesDAO;
          final allCategories = await categoriesDAO.getAllCategories();

          // Find the first category by sorting category IDs
          if(allCategories.isNotEmpty) {
            allCategories.sort((a, b) => int.parse(a.categoryId).compareTo(int.parse(b.categoryId)));
            final firstCategoryId = allCategories.first.categoryId;

            // If this is the first category, save it to current phrasers
            if(listModel[0].categoryId == firstCategoryId) {
              CurrentPhrasersDAO currentPhraserDAO = database.currentPhraserDAO;
              await currentPhraserDAO.deleteCurrentPhrasers();
              await currentPhraserDAO.insertAllCurrentPhrasers(listModel);
              testPrint('First app start: ${listModel[0].categoryName} (ID: ${listModel[0].categoryId}) quotes saved to current phrasers');
              DataRepository().currentPhrasersList = listModel;
              DataRepository().addToAllQuotes(listModel);
              Preferences.instance.currentPhraserPosition = 0;
              debugPrint('---> First category loaded with ${listModel.length} quotes');
            }
          }
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