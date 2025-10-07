import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/services/view_model/categories_list_view_model.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/utils.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';

class InitialDataLoadingScreen extends StatefulWidget {
  const InitialDataLoadingScreen({Key? key}) : super(key: key);

  @override
  State<InitialDataLoadingScreen> createState() => _InitialDataLoadingScreenState();
}

class _InitialDataLoadingScreenState extends State<InitialDataLoadingScreen> {
  final _categoriesListViewModel = Get.put(CategoriesListViewModel());
  String _loadingStatus = 'Fetching data...';
  int _totalCategories = 0;
  int _loadedCategories = 0;

  @override
  void initState() {
    super.initState();
    _startDataFetching();
  }

  Future<void> _startDataFetching() async {
    try {
      setState(() {
        _loadingStatus = 'Fetching categories...';
      });

      // Fetch categories first
      await _fetchCategories();

      setState(() {
        _loadingStatus = 'Fetching sections...';
      });

      // Fetch sections
      await _fetchSections();

      // Mark data as loaded
      Preferences.instance.isInitialDataLoaded = true;

      setState(() {
        _loadingStatus = 'Data loaded successfully!';
      });

      // Wait a bit to show success message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to the next screen based on first open status
      if (Preferences.instance.isFirstOpen) {
        Get.offAllNamed(RouteHelper.introductionScreen);
      } else {
        Get.offAllNamed(RouteHelper.phraserScreen);
      }
    } catch (e) {
      testPrint('Error in initial data loading: $e');
      setState(() {
        _loadingStatus = 'Error loading data. Please check your connection.';
      });

      // Show retry option after a delay
      await Future.delayed(const Duration(seconds: 2));
      _showRetryDialog();
    }
  }

  Future<void> _fetchCategories() async {
    await _categoriesListViewModel.getCategories();

    // Wait for categories to be inserted into DB
    await Future.delayed(const Duration(milliseconds: 500));

    // Get total categories count
    final database = FloorDB.instance.floorDatabase;
    final categoriesDAO = database.categoriesDAO;
    final categories = await categoriesDAO.getAllCategories();

    setState(() {
      _totalCategories = categories.length;
    });

    // Fetch phrasers for each category
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      setState(() {
        _loadingStatus = 'Loading ${category.categoryName}... (${i + 1}/$_totalCategories)';
        _loadedCategories = i + 1;
      });

      await _categoriesListViewModel.getPhrasersByCategory(category.categoryId.toString());

      // Small delay to allow UI update
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _fetchSections() async {
    await _categoriesListViewModel.getSectionsList();
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Data Loading Failed'),
        content: const Text('Unable to load initial data. Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startDataFetching();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
              Text(
                _loadingStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_totalCategories > 0) ...[
                const SizedBox(height: 16),
                Text(
                  '$_loadedCategories / $_totalCategories categories loaded',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _loadedCategories / _totalCategories,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
