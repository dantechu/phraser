import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/consts/text_themes.dart';
import 'package:phraser/consts/theme_images_list.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/screens/categories_list_screen.dart';
import 'package:phraser/screens/habit_stats_screen.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/widget_service.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/share_dialog.dart';
import 'package:phraser/util/utils.dart';

import '../services/view_model/phraser_view_model.dart';
import '../services/view_model/viewing_mode_view_model.dart';
import 'mood_selection/mood_selection_screen.dart';
import 'mood_selection/view_model/mood_selection_view_model.dart';
import 'habit_builder_screen.dart';
import 'settings/settings_screen.dart';
import 'theme/phraser_theme_list_screen.dart';

class PhraserViewScreen extends StatefulWidget {
  const PhraserViewScreen({super.key});

  @override
  State<PhraserViewScreen> createState() => _PhraserViewScreenState();
}

class _PhraserViewScreenState extends State<PhraserViewScreen> {
  final _phraserViewModel = Get.put(PhraserViewModel());
  final _viewingModeViewModel = Get.put(ViewingModeViewModel());
  final FlutterTts _flutterTts = FlutterTts();
  String selectedTab = 'Categories';
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _phraserViewModel.themePosition.value = Preferences.instance.textThemePosition;
    selectedTab = Preferences.instance.selectedNavigationTab;
    AdsHelper.loadAdmobBannerAd();
    _initializeTts();

    // Restore the last selected tab content after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSelectedTabContent();

      // Update widget with all current quotes for auto-cycling
      _updateWidgetData();
    });
  }

  void _updateWidgetData() async {
    try {
      // Update widget with current phraser list so it can auto-cycle
      await WidgetService().updateWidget();
      debugPrint('✅ Widget data updated with ${DataRepository().currentPhrasersList.length} quotes');
    } catch (e) {
      debugPrint('❌ Error updating widget data: $e');
    }
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _restoreSelectedTabContent() {
    // This method handles restoring the content based on the selected tab
    // For now, we just ensure the selected state is properly set
    // The actual content restoration happens when user navigates
    setState(() {
      // Trigger a rebuild to show the correct selected state
    });
  }

  int _getInitialPage() {
    // Get the last viewed position from preferences
    final savedPosition = Preferences.instance.currentPhraserPosition;
    final currentListLength = DataRepository().currentPhrasersList.length;

    // If no quotes or saved position is invalid, start from 0
    if (currentListLength == 0 || savedPosition < 0) {
      return 0;
    }

    // If saved position is beyond the current list length, start from 0
    // This can happen when switching between different quote lists (categories, habits, moods)
    if (savedPosition >= currentListLength) {
      Preferences.instance.currentPhraserPosition = 0;
      return 0;
    }

    return savedPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final vm = _phraserViewModel;
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // Background Image
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset(
                    ThemeImagesList.themeImagesList[vm.themePosition.value].themeImage,
                    key: ValueKey('theme_${vm.themePosition.value}'),
                    fit: BoxFit.fill,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),

                // Main Content - Quotes Carousel
                CarouselSlider(
                  key: ValueKey('carousel_${DataRepository().currentPhrasersList.length}_${DataRepository().currentPhrasersList.isNotEmpty ? DataRepository().currentPhrasersList.first.phraserId : "empty"}'),
                  options: CarouselOptions(
                    onPageChanged: (int index, _) async {
                      Preferences.instance.currentPhraserPosition = index;
                      if (DataRepository().currentPhrasersList.isNotEmpty && index < DataRepository().currentPhrasersList.length) {
                        final currentQuote = DataRepository().currentPhrasersList[index];
                        _phraserViewModel.isFavorites(currentQuote);

                        // Update home screen widget with current quote
                        WidgetService().updateWidgetWithQuote(currentQuote);
                      }
                      if (Preferences.instance.textThemePosition == 0) {
                        Random random = Random();
                        int randomPosition = random.nextInt(ThemeImagesList.themeImagesList.length);
                        _phraserViewModel.changeThemePosition(randomPosition);
                      }
                      testPrint('onPageChanged and new Position is ${vm.themePosition.value}');
                    },
                    initialPage: _getInitialPage(),
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    scrollDirection: Axis.vertical,
                    enableInfiniteScroll: DataRepository().currentPhrasersList.length > 1,
                  ),
                  items: DataRepository().currentPhrasersList.map((item) {
                    return Stack(
                      children: [
                        // Quote Text
                        getTextTheme(
                          context,
                          item.quote,
                          vm.themePosition.value,
                          MediaQuery.of(context).size.height,
                          ThemeImagesList.themeImagesList[vm.themePosition.value].textFontFamily,
                          ThemeImagesList.themeImagesList[vm.themePosition.value].textColor,
                          ThemeImagesList.themeImagesList[vm.themePosition.value].textSize,
                          false,
                          ThemeImagesList.themeImagesList[vm.themePosition.value].textWeight,
                        ),
                        
                        // Favorite and Share Buttons
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 166.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Favorite Button
                                GetBuilder<PhraserViewModel>(
                                  builder: (vm) => GestureDetector(
                                    onTap: () async {
                                      try { 
                                        final database = FloorDB.instance.floorDatabase;
                                        FavoritesDAO dao = database.favoritesDAO;
                                        if (!vm.isFavorite) {
                                          await dao.addPhraserToFavorite(item);
                                        } else {
                                          await dao.removeFromFavorites(item);
                                        }
                                        // Clear cache and force refresh of favorite state
                                        vm.clearCachedPhraserId();
                                        await vm.isFavorites(item);
                                      } catch (e,s) {
                                        print('Error saving favorite: $e | $s');
                                      }
                                    },
                                    child: Icon(
                                      vm.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      size: 30.0,
                                      color: vm.isFavorite
                                          ? Colors.red
                                          : ThemeImagesList.themeImagesList[_phraserViewModel.themePosition.value].textColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 30.0),

                                // Text-to-Speech Button
                                GestureDetector(
                                  onTap: () async {
                                    if (_isSpeaking) {
                                      await _flutterTts.stop();
                                      setState(() {
                                        _isSpeaking = false;
                                      });
                                    } else {
                                      setState(() {
                                        _isSpeaking = true;
                                      });
                                      await _flutterTts.speak(item.quote);
                                    }
                                  },
                                  child: Icon(
                                    _isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up,
                                    size: 30.0,
                                    color: ThemeImagesList.themeImagesList[vm.themePosition.value].textColor,
                                  ),
                                ),

                                const SizedBox(width: 30.0),

                                // Share Button
                                GestureDetector(
                                  onTap: () async {
                                    await Future.delayed(const Duration(microseconds: 200), () {
                                      showShareDialog(
                                        context: context,
                                        themeModel: ThemeImagesList.themeImagesList[vm.themePosition.value],
                                        textToShare: item.quote,
                                        themePosition: vm.themePosition.value,
                                      );
                                    });
                                  },
                                  child: Icon(
                                    Icons.share,
                                    size: 30.0,
                                    color: ThemeImagesList.themeImagesList[vm.themePosition.value].textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

                // Top Left - Habit Progress Icon (only visible when Habits tab is selected)
                if (selectedTab == 'Habits' && _hasUserHabits())
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: _navigateToHabitStats,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[850]!.withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.track_changes,
                              size: 20,
                              color: kPrimaryColor,
                            ),
                            // Progress indicator dot
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Top Right - Settings Icon
                Positioned(
                  top: 50,
                  right: 20,
                  child: GestureDetector(
                    onTap: _navigateToSettings,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[850]!.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),

                // Clean Bottom Navigation
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[850]!.withOpacity(0.95)
                          : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Categories
                        _buildNavButton(
                          icon: _viewingModeViewModel.isCurrentMode(ViewingMode.categories)
                              ? _viewingModeViewModel.getCurrentModeIcon()
                              : Icons.category_outlined,
                          label: _viewingModeViewModel.isCurrentMode(ViewingMode.categories)
                              ? _viewingModeViewModel.getCurrentModeDisplayTextEllipsed(maxLength: 10)
                              : 'Categories',
                          onTap: () => _navigateToCategories(),
                          isSelected: _viewingModeViewModel.isCurrentMode(ViewingMode.categories),
                        ),
                        
                        // Mood Quotes (NEW)
                        _buildNavButton(
                          icon: _viewingModeViewModel.isCurrentMode(ViewingMode.mood)
                              ? _viewingModeViewModel.getCurrentModeIcon()
                              : Icons.psychology_outlined,
                          label: _viewingModeViewModel.isCurrentMode(ViewingMode.mood)
                              ? _viewingModeViewModel.getCurrentModeDisplayTextEllipsed(maxLength: 10)
                              : 'Mood',
                          onTap: () => _navigateToMoodQuotes(),
                          isSelected: _viewingModeViewModel.isCurrentMode(ViewingMode.mood),
                        ),
                        
                        // Habit Builder (NEW)
                        _buildNavButton(
                          icon: _viewingModeViewModel.isCurrentMode(ViewingMode.habits)
                              ? _viewingModeViewModel.getCurrentModeIcon()
                              : Icons.track_changes_outlined,
                          label: _viewingModeViewModel.isCurrentMode(ViewingMode.habits)
                              ? _viewingModeViewModel.getCurrentModeDisplayTextEllipsed(maxLength: 10)
                              : 'Habits',
                          onTap: () => _navigateToHabits(),
                          isSelected: _viewingModeViewModel.isCurrentMode(ViewingMode.habits),
                        ),
                        
                        // AI Chat
                        _buildNavButton(
                          icon: Icons.chat_outlined,
                          label: 'AI Chat',
                          onTap: () => _navigateToAIChat(),
                          isSelected: _viewingModeViewModel.isCurrentMode(ViewingMode.aiChat),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
    );
  }

  // Helper method to build navigation buttons
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? kPrimaryColor.withOpacity(0.15)
                  : (isDark ? Colors.grey[700]!.withOpacity(0.3) : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected 
                  ? kPrimaryColor
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected 
                  ? kPrimaryColor
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to handle tab selection
  void _selectTab(String tabName) {
    setState(() {
      selectedTab = tabName;
    });
    Preferences.instance.selectedNavigationTab = tabName;
  }

  
  // Navigation Methods
  void _navigateToCategories() {
    _viewingModeViewModel.switchToCategories();
    _selectTab('Categories');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriesListScreen()),
    ).then((value) {
      setState(() {
        testPrint('setState called with data length: ${DataRepository().currentPhrasersList.length}');
      });
    });
  }

  void _navigateToMoodQuotes() async {
    _viewingModeViewModel.switchToMood();
    _selectTab('Mood');
    
    // Navigate to the advanced mood selection screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodSelectionScreen(
          onMoodSelected: (mood, intensity) async {
            // Handle mood selection and apply filters
            await _handleMoodSelection(mood, intensity);
          },
        ),
      ),
    );
    
    // If mood was selected via navigation result, handle it
    if (result != null && result is Map<String, dynamic>) {
      final mood = result['mood'];
      final intensity = result['intensity'];
      if (mood != null) {
        await _handleMoodSelection(mood, intensity);
      }
    }
  }
  
  Future<void> _handleMoodSelection(dynamic mood, dynamic intensity) async {
    // Get the mood selection view model
    final moodViewModel = Get.put(MoodSelectionViewModel());
    
    // Save the mood entry and filter quotes
    await moodViewModel.saveMoodEntry(mood, intensity);
    
    // Update viewing mode with selected mood
    _viewingModeViewModel.updateMoodName(mood.toString().split('.').last);
    
    // Reset carousel position to start
    Preferences.instance.currentPhraserPosition = 0;
    
    // Force rebuild of the entire widget to reflect new filtered quotes
    setState(() {
      // This will trigger a complete rebuild of the widget tree
    });
    
    // Update favorites for the first filtered quote
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (DataRepository().currentPhrasersList.isNotEmpty) {
        _phraserViewModel.isFavorites(DataRepository().currentPhrasersList[0]);
      }
    });
    
    // Refresh the phraser view model to update UI
    final phraserViewModel = Get.find<PhraserViewModel>();
    phraserViewModel.update();
    
  }

  void _navigateToHabits() async {
    _viewingModeViewModel.switchToHabits();
    _selectTab('Habits');
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HabitBuilderScreen()),
    );

    // Reload quotes from database after habit selection
    // This ensures we get the exact quotes that were saved
    debugPrint('🔄 Returned from habit builder - reloading from database');

    try {
      final database = FloorDB.instance.floorDatabase;
      final currentPhraserDAO = database.currentPhraserDAO;
      final quotes = await currentPhraserDAO.getAllCurrentPhrasers();

      debugPrint('📊 Loaded ${quotes.length} quotes from database');

      // Update DataRepository with quotes from database
      DataRepository().updateCurrentPhrasersList(quotes, fromHabits: true);
      DataRepository().saveOriginalPhrasersList();

      // Position should already be set to 0 by habit builder
      debugPrint('🎯 Starting from position: ${Preferences.instance.currentPhraserPosition}');

      // Force rebuild with new quotes
      setState(() {
        testPrint('Triggering carousel rebuild with habit quotes');
      });

      // Update favorites for the first quote
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (DataRepository().currentPhrasersList.isNotEmpty) {
          _phraserViewModel.clearCachedPhraserId();
          _phraserViewModel.isFavorites(DataRepository().currentPhrasersList[0]);
        }
      });
    } catch (e) {
      debugPrint('❌ Error loading quotes from database: $e');
    }
  }
  
  void _navigateToAIChat() {
    _viewingModeViewModel.switchToAIChat();
    _selectTab('AI Chat');
    Get.toNamed(RouteHelper.chatScreen);
  }

  void _navigateToThemes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhraserThemeListScreen(
          onThemeSelected: (index) {
            // Update theme immediately when selected
            _phraserViewModel.changeThemePosition(index);
          },
        ),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToHabitStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HabitStatsScreen()),
    );
  }

  // Helper method to check if user has any habits set
  bool _hasUserHabits() {
    final savedHabits = Preferences.instance.getStringList('user_habits') ?? [];
    return savedHabits.isNotEmpty;
  }
}