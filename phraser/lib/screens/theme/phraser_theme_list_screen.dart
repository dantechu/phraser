import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/consts/text_themes.dart';
import 'package:phraser/consts/theme_images_list.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/colors.dart';

class PhraserThemeListScreen extends StatefulWidget {
  final Function(int)? onThemeSelected;
  
  const PhraserThemeListScreen({Key? key, this.onThemeSelected}) : super(key: key);

  @override
  State<PhraserThemeListScreen> createState() => _PhraserThemeListScreenState();
}

class _PhraserThemeListScreenState extends State<PhraserThemeListScreen> {
  int selectedThemeIndex = 0;
  
  @override
  void initState() {
    super.initState();
    selectedThemeIndex = Preferences.instance.textThemePosition;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: Column(
          children: [
            // Original App Bar (Keep as requested)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 20.0, bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 27.0,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Text(
                      'Themes',
                      style: TextStyle(
                        fontSize: 25.0, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8.0),
            
            // Enhanced Grid View
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.builder(
                  itemCount: ThemeImagesList.themeImagesList.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final isSelected = selectedThemeIndex == index;
                    
                    return GestureDetector(
                      onTap: () async {
                        // Update local state immediately for visual feedback
                        setState(() {
                          selectedThemeIndex = index;
                        });
                        
                        // Save the preference first
                        Preferences.instance.textThemePosition = index;
                        
                        // Call the callback immediately to update the theme
                        if (widget.onThemeSelected != null) {
                          widget.onThemeSelected!(index);
                        }
                        
                        // Add a small delay to ensure the theme change is processed
                        await Future.delayed(const Duration(milliseconds: 200));
                        
                        // Then navigate back with the selected index
                        if (mounted) {
                          Navigator.pop(context, index);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? kPrimaryColor 
                                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? kPrimaryColor.withOpacity(0.3)
                                  : Colors.black.withOpacity(isDark ? 0.2 : 0.1),
                              blurRadius: isSelected ? 12 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Image
                              Image.asset(
                                ThemeImagesList.themeImagesList[index].themeImage,
                                fit: BoxFit.cover,
                              ),
                              
                              // Overlay for better text visibility
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                              
                              
                              
                              // Selection Indicator
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Selected Theme Info
            if (selectedThemeIndex >= 0 && selectedThemeIndex < ThemeImagesList.themeImagesList.length)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kPrimaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        selectedThemeIndex == 0 ? Icons.shuffle : Icons.palette,
                        color: kPrimaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedThemeIndex == 0 ? 'Random Theme' : 'Theme ${selectedThemeIndex}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            selectedThemeIndex == 0 
                                ? 'Automatically changes themes' 
                                : 'Fixed theme selection',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 5.0),
            
            // Ad Banner (Keep as original)
            if (!Preferences.instance.isPremiumApp &&
                AdsHelper.themesBannerAd.bannerAd != null &&
                AdsHelper.themesBannerAd.isAdLoaded != null &&
                AdsHelper.themesBannerAd.isAdLoaded!)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    height: 60,
                    child: AdWidget(ad: AdsHelper.themesBannerAd.bannerAd!),
                  ),
                ),
              ),
              
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}