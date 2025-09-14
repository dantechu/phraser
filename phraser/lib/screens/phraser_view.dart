import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/consts/text_themes.dart';
import 'package:phraser/consts/theme_images_list.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/screens/categories_list_screen.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/share_dialog.dart';
import 'package:phraser/util/utils.dart';

import '../services/view_model/phraser_view_model.dart';
import 'mood_quotes_screen.dart';
import 'habit_builder_screen.dart';
import 'settings/settings_screen.dart';

class PhraserViewScreen extends StatefulWidget {
  const PhraserViewScreen({super.key});

  @override
  State<PhraserViewScreen> createState() => _PhraserViewScreenState();
}

class _PhraserViewScreenState extends State<PhraserViewScreen> {
  final CarouselController _carouselController = CarouselController();
  final _phraserViewModel = Get.put(PhraserViewModel());

  @override
  void initState() {
    super.initState();
    _phraserViewModel.themePosition = Preferences.instance.textThemePosition;
    AdsHelper.loadAdmobBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PhraserViewModel>(
        init: PhraserViewModel(),
        builder: (vm) {
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
                    ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].themeImage,
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
                      testPrint('onPageChanged and new Position is ${_phraserViewModel.themePosition}');
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
                          _phraserViewModel.themePosition,
                          MediaQuery.of(context).size.height,
                          ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].textFontFamily,
                          ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].textColor,
                          ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].textSize,
                          false,
                          ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].textWeight,
                        ),
                        
                        // Favorite and Share Buttons
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 120.0),
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
                                        : ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].textColor,
                                  ),
                                ),
                                
                                const SizedBox(width: 30.0),
                                
                                // Share Button
                                GestureDetector(
                                  onTap: () async {
                                    await Future.delayed(const Duration(microseconds: 200), () {
                                      showShareDialog(
                                        context: context,
                                        themeModel: ThemeImagesList.themeImagesList[_phraserViewModel.themePosition],
                                        textToShare: item.quote,
                                        themePosition: _phraserViewModel.themePosition,
                                      );
                                    });
                                  },
                                  child: Icon(
                                    Icons.share,
                                    size: 30.0,
                                    color: ThemeImagesList.themeImagesList[_phraserViewModel.themePosition].textColor,
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

                // Settings Icon in Top Right
                Positioned(
                  top: 50,
                  right: 20,
                  child: GestureDetector(
                    onTap: _navigateToSettings,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: Colors.black87,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
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
                        
                        // Themes
                        _buildNavButton(
                          icon: Icons.palette_outlined,
                          label: 'Themes',
                          onTap: () => _navigateToThemes(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to build navigation buttons
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Methods
  void _navigateToCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriesListScreen()),
    ).then((value) {
      setState(() {
        testPrint('setState called with data length: ${DataRepository().currentPhrasersList.length}');
      });
    });
  }

  void _navigateToMoodQuotes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoodQuotesScreen()),
    );
  }

  void _navigateToHabits() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HabitBuilderScreen()),
    );
  }

  void _navigateToThemes() {
    Get.toNamed(RouteHelper.phraserThemeListScreen)?.then((value) {
      _phraserViewModel.changeThemePosition(Preferences.instance.textThemePosition);
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}