
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
  
  // Store ALL quotes from ALL categories for global mood filtering
  List<Phraser> _allQuotesFromAllCategories = [];
  
  // Use a Set to track existing IDs for fast duplicate checking
  Set<String> _existingQuoteIds = {};

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
  
  // Method to store all quotes from all categories
  void addToAllQuotes(List<Phraser> quotes) {
    // Add unique quotes only (avoid duplicates) using fast Set lookup
    for (final quote in quotes) {
      if (!_existingQuoteIds.contains(quote.phraserId)) {
        _allQuotesFromAllCategories.add(quote);
        _existingQuoteIds.add(quote.phraserId);
      }
    }
  }
  
  // Get all quotes from all categories for mood filtering
  List<Phraser> getAllQuotes() {
    return _allQuotesFromAllCategories;
  }
  
  // Clear all stored quotes (useful for app refresh)
  void clearAllQuotes() {
    _allQuotesFromAllCategories.clear();
    _existingQuoteIds.clear();
  }




}