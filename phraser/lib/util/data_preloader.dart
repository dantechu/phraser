import 'package:flutter/foundation.dart';
import 'package:phraser/floor_db/categories_dao.dart';
import 'package:phraser/floor_db/current_phraser_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/services/view_model/categories_list_view_model.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/utils.dart';

class DataPreloader {
  static final DataPreloader _instance = DataPreloader._internal();
  static DataPreloader get instance => _instance;
  DataPreloader._internal();

  bool _isPreloadingInProgress = false;
  bool _isPreloadingComplete = false;

  /// Check if all essential data has been preloaded
  bool get isPreloadingComplete => _isPreloadingComplete;

  /// Preload all essential data for the app
  Future<void> preloadAllData() async {
    if (_isPreloadingInProgress || _isPreloadingComplete) {
      debugPrint('DataPreloader: Preloading already in progress or complete');
      return;
    }

    _isPreloadingInProgress = true;
    debugPrint('DataPreloader: Starting comprehensive data preload...');

    try {
      final database = FloorDB.instance.floorDatabase;
      
      // 1. Load categories and sections first
      await _loadCategoriesAndSections();
      
      // 2. Check if we need to preload quotes for all categories
      if (!Preferences.instance.isAllQuotesPreloaded) {
        await _preloadAllQuotesForAllCategories();
        Preferences.instance.isAllQuotesPreloaded = true;
      } else {
        debugPrint('DataPreloader: All quotes already preloaded');
      }
      
      // 3. Ensure current category is set
      await _ensureCurrentCategoryIsSet();
      
      // 4. Load current phrasers list
      await _loadCurrentPhrasersList();
      
      _isPreloadingComplete = true;
      debugPrint('DataPreloader: All data preloading completed successfully');
      
    } catch (e) {
      debugPrint('DataPreloader: Error during preloading: $e');
      _isPreloadingComplete = false;
    } finally {
      _isPreloadingInProgress = false;
    }
  }

  /// Load categories and sections
  Future<void> _loadCategoriesAndSections() async {
    final database = FloorDB.instance.floorDatabase;
    
    if (Preferences.instance.isCategoriesPresent) {
      // Load from local database
      final categoriesDAO = database.categoriesDAO;
      final sectionDAO = database.sectionDAO;
      
      final categories = await categoriesDAO.getAllCategories();
      final sections = await sectionDAO.getAllSection();
      
      DataRepository().categoriesList = categories;
      DataRepository().sectionList = sections;
      
      debugPrint('DataPreloader: Loaded ${categories.length} categories and ${sections.length} sections from local DB');
    } else {
      // Categories not present, they will be loaded by CategoriesListViewModel
      debugPrint('DataPreloader: Categories not present in local DB, will be loaded by network');
    }
  }

  /// Preload quotes for all categories to ensure offline access
  Future<void> _preloadAllQuotesForAllCategories() async {
    debugPrint('DataPreloader: Starting to preload quotes for all categories...');
    
    final database = FloorDB.instance.floorDatabase;
    final phrasersDAO = database.phraserDAO;
    
    // Get all categories
    List<Categories> categories = DataRepository().categoriesList;
    if (categories.isEmpty) {
      final categoriesDAO = database.categoriesDAO;
      categories = await categoriesDAO.getAllCategories();
    }
    
    if (categories.isEmpty) {
      debugPrint('DataPreloader: No categories available for preloading quotes');
      return;
    }

    // Load quotes for each category and store in database
    for (final category in categories) {
      try {
        // Check if quotes for this category already exist
        final existingQuotes = await phrasersDAO.getAllPhrasers(category.categoryName);
        
        if (existingQuotes.isEmpty) {
          debugPrint('DataPreloader: No quotes found for ${category.categoryName}, will be loaded on demand');
        } else {
          // Add to global repository for mood filtering
          DataRepository().addToAllQuotes(existingQuotes);
          debugPrint('DataPreloader: Loaded ${existingQuotes.length} quotes for ${category.categoryName}');
        }
      } catch (e) {
        debugPrint('DataPreloader: Error loading quotes for ${category.categoryName}: $e');
      }
    }
    
    debugPrint('DataPreloader: Completed preloading quotes for all available categories');
  }

  /// Ensure that a current category is always set
  Future<void> _ensureCurrentCategoryIsSet() async {
    final savedCategoryName = Preferences.instance.savedCategoryName;
    
    if (savedCategoryName == null || savedCategoryName.isEmpty) {
      // No category selected, set a default one
      final categories = DataRepository().categoriesList;
      if (categories.isNotEmpty) {
        // Find 'Self Respect' or use first available category
        Categories? defaultCategory;
        
        for (final category in categories) {
          if (category.categoryName.toLowerCase().contains('self respect') ||
              category.categoryName.toLowerCase().contains('personal growth')) {
            defaultCategory = category;
            break;
          }
        }
        
        defaultCategory ??= categories.first;
        
        Preferences.instance.savedCategoryName = defaultCategory.categoryName;
        debugPrint('DataPreloader: Set default category to: ${defaultCategory.categoryName}');
        
        // Load quotes for this default category
        await _loadQuotesForCategory(defaultCategory.categoryName);
      }
    } else {
      debugPrint('DataPreloader: Current category already set: $savedCategoryName');
      // Ensure quotes are loaded for the saved category
      await _loadQuotesForCategory(savedCategoryName);
    }
  }

  /// Load quotes for a specific category
  Future<void> _loadQuotesForCategory(String categoryName) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final phrasersDAO = database.phraserDAO;
      final currentPhrasersDAO = database.currentPhraserDAO;
      
      final quotes = await phrasersDAO.getAllPhrasers(categoryName);
      
      if (quotes.isNotEmpty) {
        // Clear current phrasers and set new ones
        try {
          await currentPhrasersDAO.deleteCurrentPhrasers();
        } catch (e) {
          debugPrint('DataPreloader: Table not created yet: $e');
        }
        
        await currentPhrasersDAO.insertAllCurrentPhrasers(quotes);
        DataRepository().currentPhrasersList = quotes;
        DataRepository().addToAllQuotes(quotes);
        
        debugPrint('DataPreloader: Loaded ${quotes.length} quotes for category: $categoryName');
      } else {
        debugPrint('DataPreloader: No quotes found for category: $categoryName');
      }
    } catch (e) {
      debugPrint('DataPreloader: Error loading quotes for category $categoryName: $e');
    }
  }

  /// Load current phrasers list from database
  Future<void> _loadCurrentPhrasersList() async {
    try {
      final database = FloorDB.instance.floorDatabase;
      final currentPhrasersDAO = database.currentPhraserDAO;
      
      final currentQuotes = await currentPhrasersDAO.getAllCurrentPhrasers();
      
      if (currentQuotes.isNotEmpty) {
        DataRepository().currentPhrasersList = currentQuotes;
        DataRepository().addToAllQuotes(currentQuotes);
        debugPrint('DataPreloader: Loaded ${currentQuotes.length} current phrasers from database');
      } else {
        debugPrint('DataPreloader: No current phrasers found in database');
        // Try to load default category quotes if current list is empty
        await _ensureCurrentCategoryIsSet();
      }
    } catch (e) {
      debugPrint('DataPreloader: Error loading current phrasers list: $e');
    }
  }

  /// Smart category switching with local data check
  Future<bool> switchToCategory(String categoryName) async {
    try {
      debugPrint('DataPreloader: Switching to category: $categoryName');
      
      final database = FloorDB.instance.floorDatabase;
      final phrasersDAO = database.phraserDAO;
      final currentPhrasersDAO = database.currentPhraserDAO;
      
      // Check if quotes exist locally
      final localQuotes = await phrasersDAO.getAllPhrasers(categoryName);
      
      if (localQuotes.isNotEmpty) {
        // Quotes exist locally, switch immediately
        debugPrint('DataPreloader: Found ${localQuotes.length} local quotes for $categoryName');
        
        try {
          await currentPhrasersDAO.deleteCurrentPhrasers();
        } catch (e) {
          debugPrint('DataPreloader: Table not created yet: $e');
        }
        
        await currentPhrasersDAO.insertAllCurrentPhrasers(localQuotes);
        DataRepository().currentPhrasersList = localQuotes;
        DataRepository().addToAllQuotes(localQuotes);
        
        // Save the selected category
        Preferences.instance.savedCategoryName = categoryName;
        Preferences.instance.currentPhraserPosition = 0;
        
        debugPrint('DataPreloader: Successfully switched to category: $categoryName');
        return true;
      } else {
        // No local quotes, need to load from network
        debugPrint('DataPreloader: No local quotes for $categoryName, requires network loading');
        return false;
      }
    } catch (e) {
      debugPrint('DataPreloader: Error switching to category $categoryName: $e');
      return false;
    }
  }

  /// Reset all data (useful for app refresh or logout)
  Future<void> resetAllData() async {
    try {
      _isPreloadingComplete = false;
      DataRepository().clearAllQuotes();
      DataRepository().currentPhrasersList.clear();
      Preferences.instance.isAllQuotesPreloaded = false;
      debugPrint('DataPreloader: All data reset successfully');
    } catch (e) {
      debugPrint('DataPreloader: Error resetting data: $e');
    }
  }
}