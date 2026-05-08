import 'dart:io';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/consts/const_strings.dart';
import 'package:phraser/helper/navigation_helper.dart';
import 'package:phraser/screens/favorites_screen/favorites_screen.dart';
import 'package:phraser/screens/in_app_purchase/preimum_app_screen.dart';
import 'package:phraser/screens/in_app_purchase/premium_status_screen.dart';
import 'package:phraser/screens/statistics/statistics_screen.dart';
import 'package:phraser/widgets/region_selection_dialog.dart';
import 'package:phraser/util/preferences_util.dart';
import 'package:phraser/screens/notification_settings/free_notifications_settings.dart';
import 'package:phraser/screens/notification_settings/notification_settings.dart';
import 'package:phraser/screens/theme/AppThemeScreen.dart';
import 'package:phraser/theme/theme_controller.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/status_bar_helper.dart';
import 'package:phraser/services/widget_service.dart';

import '../../widgets/simple_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSync = false;
  bool isVacationMode = false;
  String title = '';
  String timeZone = '';
  String themeTitle = '';
  String regionTitle = '';
  String widgetIntervalTitle = '';
  int selectedIndex = 0;
  late RateMyApp rateMyApp;

  @override
  void initState() {
    super.initState();
    init();
  }

  void sync(bool value) {
    isSync = value;
    setState(() {});
  }

  void mode(bool value) {
    isVacationMode = value;
    setState(() {});
  }

  Future<void> init() async {
     rateMyApp = RateMyApp(
      preferencesPrefix: 'phraser_',
      minDays: 0,
      minLaunches: 0,
      remindDays: 0,
      remindLaunches: 0,
      googlePlayIdentifier: 'com.phrsre.daily.affirmation.phraser',
      appStoreIdentifier: '6447237178',
    );
    
    // Load current theme from ThemeController
    final currentTheme = ThemeController().themeMode;
    
    // Load current region
    final currentRegion = PreferencesUtil.getSelectedRegion();

    // Load current widget refresh interval
    final currentInterval = Preferences.instance.widgetRefreshInterval;

    setState(() {
      switch (currentTheme) {
        case ThemeMode.light:
          themeTitle = 'Light';
          break;
        case ThemeMode.dark:
          themeTitle = 'Dark';
          break;
        case ThemeMode.system:
          themeTitle = 'System';
          break;
      }

      // Set region title
      if (currentRegion == null || currentRegion.isEmpty) {
        regionTitle = 'All Regions';
      } else {
        regionTitle = currentRegion;
      }

      // Set widget interval title
      widgetIntervalTitle = '$currentInterval min';
    });
  }

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return StatusBarHelper.standardSafeArea(
      context: context,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40, left: 16, right: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // General Section Card
              _buildSectionCard(
                context,
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    iconColor: Colors.amber,
                    title: 'Manage Subscription',
                    subtitle: 'Premium features & billing',
                    onTap: () {
                      // Check if user is premium
                      final isPremium = Preferences.instance.isPremiumApp;
                      if (isPremium) {
                        // Show premium status screen for premium users
                        NavigationHelper.pushRoute(context, const PremiumStatusScreen());
                      } else {
                        // Show premium purchase screen for non-premium users
                        NavigationHelper.pushRoute(context, const PremiumAppScreen());
                      }
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.palette_outlined,
                    iconColor: Colors.blue,
                    title: 'Theme',
                    subtitle: 'Light, dark, or system',
                    trailing: Text(
                      themeTitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _showThemeDialog(context),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.orange,
                    title: 'Reminders',
                    subtitle: 'Daily notification settings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FreeNotificationSettingsScreen(willPop: true),
                      ),
                    ),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.notification_add_outlined,
                    iconColor: Colors.purple,
                    title: 'Custom Reminders',
                    subtitle: 'Personalized notifications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationSettingsScreen(willPop: true),
                      ),
                    ),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Your Phrasers Section Card
              _buildSectionCard(
                context,
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.color_lens_outlined,
                    iconColor: Colors.purple,
                    title: 'Themes',
                    subtitle: 'Customize appearance',
                    onTap: _navigateToThemes,
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.favorite_outline,
                    iconColor: Colors.red,
                    title: 'Favorites',
                    subtitle: 'Your saved phrasers',
                    onTap: () => NavigationHelper.pushRoute(context, const FavoritesScreen()),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.refresh_outlined,
                    iconColor: Colors.teal,
                    title: 'Widget Refresh Timer',
                    subtitle: 'How often widget updates',
                    trailing: Text(
                      widgetIntervalTitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _showWidgetIntervalDialog(context),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.bar_chart_rounded,
                    iconColor: Colors.green,
                    title: 'Statistics',
                    subtitle: 'View your moods & habits progress',
                    onTap: () => NavigationHelper.pushRoute(context, const StatisticsScreen()),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.public,
                    iconColor: Colors.blue,
                    title: 'Region',
                    subtitle: 'Filter phrasers by region',
                    trailing: Text(
                      regionTitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _showRegionDialog(context),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Help Section Card
              _buildSectionCard(
                context,
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.star_outline,
                    iconColor: Colors.amber,
                    title: 'Leave valuable feedback',
                    subtitle: 'Rate and review the app',
                    onTap: showRatingDialog,
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.support_agent_outlined,
                    iconColor: Colors.teal,
                    title: 'Get Help',
                    subtitle: 'Contact support team',
                    onTap: () => _launchUrl(Uri.parse(ConstStrings.kAppContactLink)),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Other Section Card
              _buildSectionCard(
                context,
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.description_outlined,
                    iconColor: Colors.blue,
                    title: 'Terms & Conditions',
                    subtitle: 'Legal terms of service',
                    onTap: () => _launchUrl(Uri.parse(ConstStrings.kAppPrivacyLink)),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.green,
                    title: 'Privacy Policy',
                    subtitle: 'How we protect your data',
                    onTap: () => _launchUrl(Uri.parse(ConstStrings.kAppPrivacyLink)),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.email_outlined,
                    iconColor: Colors.indigo,
                    title: 'Contact Us',
                    subtitle: 'Send us a message',
                    onTap: () => _launchUrl(Uri.parse(ConstStrings.kAppContactLink)),
                    isLast: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showRatingDialog() async {
   try {
     rateMyApp.showRateDialog(
       context,
       title: 'Rate this app',
       // The dialog title.
       message: 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
       // The dialog message.
       rateButton: 'RATE',
       // The dialog "rate" button text.
       noButton: 'NO THANKS',
       // The dialog "no" button text.
       laterButton: 'MAYBE LATER',
       // The dialog "later" button text.
       listener: (
           button) { // The button click listener (useful if you want to cancel the click event).
         switch (button) {
           case RateMyAppDialogButton.rate:
             print('Clicked on "Rate".');
             break;
           case RateMyAppDialogButton.later:
             print('Clicked on "Later".');
             break;
           case RateMyAppDialogButton.no:
             print('Clicked on "No".');
             break;
         }

         return true; // Return false if you want to cancel the click event.
       },
       ignoreNativeDialog: Platform.isAndroid,
       // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
       dialogStyle: const DialogStyle(),
       // Custom dialog styles.
       onDismissed: () =>
           rateMyApp.callEvent(RateMyAppEventType
               .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
       // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
       // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
     );
   } catch(e) {
     Fluttertoast.showToast(msg: 'Unable to open rate dialog');
   }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      Fluttertoast.showToast(msg: 'Unable to launch this URL!');
    }
  }

  void _navigateToThemes() {
    Get.toNamed(RouteHelper.phraserThemeListScreen);
  }

  void _showRegionDialog(BuildContext context) {
    final currentRegion = PreferencesUtil.getSelectedRegion();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegionSelectionDialog(
          currentRegion: currentRegion,
          onRegionSelected: (selectedRegion) {
            setState(() {
              if (selectedRegion == null || selectedRegion.isEmpty) {
                regionTitle = 'All Regions';
              } else {
                regionTitle = selectedRegion;
              }
            });
          },
        );
      },
    );
  }

  void _showWidgetIntervalDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentInterval = Preferences.instance.widgetRefreshInterval;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Widget Refresh Timer',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose how often the widget updates to show a new quote',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildIntervalOption(context, 1, currentInterval == 1),
              const SizedBox(height: 8),
              _buildIntervalOption(context, 5, currentInterval == 5),
              const SizedBox(height: 8),
              _buildIntervalOption(context, 10, currentInterval == 10),
              const SizedBox(height: 8),
              _buildIntervalOption(context, 15, currentInterval == 15),
              const SizedBox(height: 8),
              _buildIntervalOption(context, 30, currentInterval == 30),
              const SizedBox(height: 8),
              _buildIntervalOption(context, 60, currentInterval == 60),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntervalOption(BuildContext context, int minutes, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String label = minutes == 1 ? '1 minute' :
                        minutes == 60 ? '1 hour' :
                        '$minutes minutes';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _selectInterval(minutes);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.grey[700] : Colors.grey[100])
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: isDark ? Colors.blue[400] : Colors.blue[600],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectInterval(int minutes) {
    // Save the interval
    Preferences.instance.widgetRefreshInterval = minutes;

    // Update local state
    setState(() {
      widgetIntervalTitle = '$minutes min';
    });

    // Show confirmation
    Fluttertoast.showToast(
      msg: 'Widget will refresh every ${minutes == 1 ? "minute" : minutes == 60 ? "hour" : "$minutes minutes"}',
      toastLength: Toast.LENGTH_SHORT,
    );

    debugPrint('✅ Widget refresh interval set to $minutes minutes');
  }

  void _showThemeDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ThemeController().themeMode;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Choose Theme',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                'Light',
                'Use light theme',
                Icons.light_mode,
                Colors.orange,
                currentTheme == ThemeMode.light,
                () => _selectTheme('Light'),
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                'Dark',
                'Use dark theme',
                Icons.dark_mode,
                Colors.indigo,
                currentTheme == ThemeMode.dark,
                () => _selectTheme('Dark'),
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                'System',
                'Follow system setting',
                Icons.settings_display,
                Colors.grey,
                currentTheme == ThemeMode.system,
                () => _selectTheme('System'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? Colors.grey[700] : Colors.grey[100])
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: isDark ? Colors.blue[400] : Colors.blue[600],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTheme(String theme) {
    ThemeMode themeMode;
    
    // Convert string to ThemeMode
    switch (theme) {
      case 'Light':
        themeMode = ThemeMode.light;
        break;
      case 'Dark':
        themeMode = ThemeMode.dark;
        break;
      case 'System':
      default:
        themeMode = ThemeMode.system;
        break;
    }
    
    // Apply theme using existing ThemeController
    ThemeController().saveTheme(themeMode);
    ThemeController().switchTheme();
    
    // Update local state
    setState(() {
      themeTitle = theme;
    });
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Items without header
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Trailing
                  if (trailing != null) ...[
                    trailing,
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Divider
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 68),
            height: 1,
            color: isDark 
                ? Colors.grey[700]?.withOpacity(0.5) 
                : Colors.grey[200],
          ),
      ],
    );
  }
}
