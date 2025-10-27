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
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startDataFetching();
  }

  Future<void> _startDataFetching() async {
    try {
      // Start sections loading in background (non-blocking)
      _fetchSections();

      // Fetch first category (this will navigate when done)
      await _fetchCategories();

    } catch (e) {
      testPrint('Error in initial data loading: $e');
      _showRetryDialog();
    }
  }

  Future<void> _fetchCategories() async {
    // Fetch categories with progress callback
    // This now loads only the first category, then continues in background
    await _categoriesListViewModel.getCategoriesWithPhrasers((categoryName, current, total) {
      // Loading silently without UI updates
    });

    // After first category is loaded, mark as ready and navigate
    Preferences.instance.isInitialDataLoaded = true;
    Preferences.instance.lastDataLoadTimestamp = DateTime.now().millisecondsSinceEpoch;

    // Navigate immediately
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;

      if (Preferences.instance.isFirstOpen) {
        Get.offAllNamed(RouteHelper.introductionScreen);
      } else {
        Get.offAllNamed(RouteHelper.phraserScreen);
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                'Loading...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
