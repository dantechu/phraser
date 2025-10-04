import 'dart:io';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/consts/const_strings.dart';
import 'package:phraser/helper/navigation_helper.dart';
import 'package:phraser/screens/favorites_screen/favorites_screen.dart';
import 'package:phraser/screens/in_app_purchase/preimum_app_screen.dart';
import 'package:phraser/screens/notification_settings/free_notifications_settings.dart';
import 'package:phraser/screens/notification_settings/notification_settings.dart';
import 'package:phraser/screens/theme/AppThemeScreen.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';

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

  }

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                    onTap: () => NavigationHelper.pushRoute(context, const PremiumAppScreen()),
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
                    onTap: () => NavigationHelper.pushRoute(context, AppThemeScreen()),
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
