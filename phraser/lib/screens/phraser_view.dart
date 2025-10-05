import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/consts/text_themes.dart';
import 'package:phraser/consts/theme_images_list.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/screens/categories_list_screen.dart';
import 'package:phraser/screens/habit_stats_screen.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/share_dialog.dart';
import 'package:phraser/util/utils.dart';

import '../services/view_model/phraser_view_model.dart';
import 'mood_quotes_screen.dart';
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
  final CarouselController _carouselController = CarouselController();
  final _phraserViewModel = Get.put(PhraserViewModel());
  final _moodViewModel = Get.put(MoodSelectionViewModel());
  String selectedTab = 'Categories';

  @override
  void initState() {
    super.initState();
    _phraserViewModel.themePosition.value = Preferences.instance.textThemePosition;
    selectedTab = Preferences.instance.selectedNavigationTab;
    AdsHelper.loadAdmobBannerAd();
    
    // Restore the last selected tab content after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSelectedTabContent();
    });
  }

  void _restoreSelectedTabContent() {
    // This method handles restoring the content based on the selected tab
    // For now, we just ensure the selected state is properly set
    // The actual content restoration happens when user navigates
    setState(() {
      // Trigger a rebuild to show the correct selected state
    });
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
                  options: CarouselOptions(
                    onPageChanged: (int index, _) {
                      Preferences.instance.currentPhraserPosition = index;
                      _phraserViewModel.isFavorites(DataRepository().currentPhrasersList[index]);
                      if (Preferences.instance.textThemePosition == 0) {
                        Random random = Random();
                        int randomPosition = random.nextInt(ThemeImagesList.themeImagesList.length);
                        _phraserViewModel.changeThemePosition(randomPosition);
                      }
                      testPrint('onPageChanged and new Position is ${vm.themePosition.value}');
                    },
                    initialPage: Preferences.instance.currentPhraserPosition,
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    scrollDirection: Axis.vertical,
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
                                GestureDetector(
                                  onTap: () {
                                    try {
                                      final database = FloorDB.instance.floorDatabase;
                                      FavoritesDAO dao = database.favoritesDAO;
                                      if (!vm.isFavorite) {
                                        vm.isFavorite = true;
                                        dao.addPhraserToFavorite(item);
                                      } else {
                                        vm.isFavorite = false;
                                        dao.removeFromFavorites(item);
                                      }
                                    } catch (e) {
                                      // Handle error
                                    }
                                  },
                                  child: Icon(
                                    vm.isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 30.0,
                                    color: vm.isFavorite
                                        ? Colors.red
                                        : ThemeImagesList.themeImagesList[vm.themePosition.value].textColor,
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
                if (selectedTab == 'Habits')
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
                          ? kPrimaryColor.withOpacity(0.9)
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
                          icon: Icons.category_outlined,
                          label: 'Categories',
                          onTap: () => _navigateToCategories(),
                        ),
                        
                        // Mood Quotes (NEW)
                        _buildNavButton(
                          icon: Icons.psychology_outlined,
                          label: 'Mood',
                          onTap: () => _navigateToMoodQuotes(),
                        ),
                        
                        // Habit Builder (NEW)
                        _buildNavButton(
                          icon: Icons.track_changes_outlined,
                          label: 'Habits',
                          onTap: () => _navigateToHabits(),
                        ),
                        
                        // AI Chat
                        _buildNavButton(
                          icon: Icons.chat_outlined,
                          label: 'AI Chat',
                          onTap: () => Get.toNamed(RouteHelper.chatScreen),
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
    final bool isSelectedTab = selectedTab == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelectedTab 
                  ? Theme.of(context).primaryColor.withOpacity(0.1) 
                  : (isDark ? Colors.grey[700]!.withOpacity(0.3) : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelectedTab 
                  ? (isDark ? Colors.white : kPrimaryColor)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelectedTab 
                  ? (isDark ? Colors.white : kPrimaryColor)
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
    
    // Apply the filtered quotes to the main view
    moodViewModel.applyMoodFilterToQuotes();
    
    // Reset carousel position to start
    Preferences.instance.currentPhraserPosition = 0;
    
    // Refresh the phraser view model to update UI
    final phraserViewModel = Get.find<PhraserViewModel>();
    phraserViewModel.update();
    
    // Show success message
    Get.snackbar(
      'Mood Set!',
      'Showing ${moodViewModel.moodFilteredQuotes.length} quotes for your ${mood.toString().split('.').last} mood',
      backgroundColor: kPrimaryColor.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _navigateToHabits() {
    _selectTab('Habits');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HabitBuilderScreen()),
    );
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
}