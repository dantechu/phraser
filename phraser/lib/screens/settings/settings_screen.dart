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
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 40, left: 0, right: 0, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 0.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close, size: 27.0,)),
                      SizedBox(width: 15.0),
                      Text('Settings', style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold ),)
                    ],
                  ),

                ),
              ),
              Text('General', style: boldTextStyle(size: 18, color: Theme.of(context).primaryColorDark,)).paddingLeft(16),
              8.height,
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: 'Manage Subscription',
                titleTextColor: Theme.of(context).primaryColorDark,
                leading: noteLeadingWidget(context, image: Icons.settings_outlined, color: Colors.grey),
                trailing: Row(
                  children: [
                    Text(themeTitle, style: secondaryTextStyle(size: 14)),
                    8.width,
                    Icon(Icons.arrow_forward_ios_rounded, color: textSecondaryColorGlobal, size: 12),
                  ],
                ),
                onTap: () async {
                  NavigationHelper.pushRoute(context, const PremiumAppScreen());
                },
              ),
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: 'Theme',
                titleTextColor: Theme.of(context).primaryColorDark,
                leading: noteLeadingWidget(context, image: Icons.ad_units, color: Colors.blue),
                trailing: Row(
                  children: [
                    Text(themeTitle, style: secondaryTextStyle(size: 14)),
                    8.width,
                    Icon(Icons.arrow_forward_ios_rounded, color: textSecondaryColorGlobal, size: 12),
                  ],
                ),
                onTap: () async {
                  NavigationHelper.pushRoute(context, AppThemeScreen());
                },
              ),
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: 'Reminders',
                titleTextColor: Theme.of(context).primaryColorDark,
                leading: noteLeadingWidget(context, image: Icons.add_alert_outlined, color: Colors.deepOrangeAccent),
                trailing: Row(
                  children: [
                    Text(timeZone, style: secondaryTextStyle(size: 14)),
                    8.width,
                    Icon(Icons.arrow_forward_ios_rounded, color: textSecondaryColorGlobal, size: 12),
                  ],
                ),
                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FreeNotificationSettingsScreen(willPop: true)));

                },
              ),
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: 'Custom Reminders',
                titleTextColor: Theme.of(context).primaryColorDark,
                leading: noteLeadingWidget(context, image: Icons.add_alert_outlined, color: Colors.deepPurpleAccent),
                trailing: Row(
                  children: [
                    Text(timeZone, style: secondaryTextStyle(size: 14)),
                    8.width,
                    Icon(Icons.arrow_forward_ios_rounded, color: textSecondaryColorGlobal, size: 12),
                  ],
                ),
                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsScreen(willPop: true)));

                },
              ),
              // SettingItemWidget(
              //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              //   title: 'Widgets',
              //   titleTextColor: Theme.of(context).primaryColorDark,
              //   leading: noteLeadingWidget(context, image: Icons.workspaces_outline, color: Colors.teal[600]),
              //   trailing: Row(
              //     children: [
              //       Text(timeZone, style: secondaryTextStyle(size: 14)),
              //       8.width,
              //       Icon(Icons.arrow_forward_ios_rounded, color: textSecondaryColorGlobal, size: 12),
              //     ],
              //   ),
              //   onTap: () async {
              //
              //   },
              // ),
              8.height,
              Text('Your Phrasers', style: boldTextStyle(size: 18, color: Theme.of(context).primaryColorDark,)).paddingLeft(16),
              8.height,
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: noteLeadingWidget(context, image: Icons.palette_outlined, color: Colors.purple),
                title: 'Themes',
                titleTextColor: Theme.of(context).primaryColorDark,
                onTap: () {
                  _navigateToThemes();
                },
              ),
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: noteLeadingWidget(context, image: Icons.favorite_outlined, color: Colors.red),
                title: 'Favorites',
                titleTextColor: Theme.of(context).primaryColorDark,
                onTap: () {
                  NavigationHelper.pushRoute(context, const FavoritesScreen());
                },
              ),
              // SettingItemWidget(
              //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              //   title: 'Search',
              //   titleTextColor: Theme.of(context).primaryColorDark,
              //   leading: noteLeadingWidget(context, image: Icons.search_outlined, color: Colors.orangeAccent),
              //   onTap: () {
              //     Fluttertoast.showToast(msg: 'Coming soon :)');
              //     // showConfirmDialogCustom(
              //     //   context,
              //     //   title: "Do you want to add this item?",
              //     //   dialogType: DialogType.DELETE,
              //     //   onAccept: (contexts) {
              //     //
              //     //   },
              //     // );
              //   },
              // ),
              8.height,
              Text('Help', style: boldTextStyle(size: 18, color: Theme.of(context).primaryColorDark,)).paddingLeft(16),
              8.height,
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: noteLeadingWidget(context, image: Icons.star_border_outlined, color: Colors.yellow[900]),
                title: 'Leave valuable feedback',
                titleTextColor: Theme.of(context).primaryColorDark,
                onTap: () {
                  showRatingDialog();
                },
              ),
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: 'Get Help',
                titleTextColor: Theme.of(context).primaryColorDark,
                leading: noteLeadingWidget(context, image: Icons.info_outline,color: Colors.brown),
                onTap: () {
                  _launchUrl(Uri.parse(ConstStrings.kAppContactLink));
                  // showConfirmDialogCustom(
                  //   context,
                  //
                  //   title: "Do you want to add this item?",
                  //   dialogType: DialogType.DELETE,
                  //   onAccept: (contexts) {
                  //
                  //   },
                  // );
                },
              ),
              8.height,
              Text('Other', style: boldTextStyle(size: 18, color: Theme.of(context).primaryColorDark,)).paddingLeft(16),
              8.height,
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: noteLeadingWidget(context, image: Icons.wysiwyg_outlined, color: Colors.lightBlue),
                title: 'Terms & Conditions',
                titleTextColor: Theme.of(context).primaryColorDark,
                onTap: () {
                  _launchUrl(Uri.parse(ConstStrings.kAppPrivacyLink));
                },
              ),
              SettingItemWidget(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: 'Privacy Policy',
                titleTextColor: Theme.of(context).primaryColorDark,
                leading: noteLeadingWidget(context, image: Icons.privacy_tip_outlined, color: Colors.orangeAccent),
                onTap: () {
                  _launchUrl(Uri.parse(ConstStrings.kAppPrivacyLink));
                  // showConfirmDialogCustom(
                  //   context,
                  //   title: "Do you want to add this item?",
                  //
                  //   dialogType: DialogType.DELETE,
                  //   onAccept: (contexts) {
                  //
                  //   },
                  // );
                },
              ),
              SettingItemWidget(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: 'Contact Us',
                titleTextColor: Theme.of(context).primaryColorDark,
                leading: noteLeadingWidget(context, image: Icons.support_agent_outlined, color: Colors.green[800]),
                onTap: () {
                  _launchUrl(Uri.parse(ConstStrings.kAppContactLink));
                  // showConfirmDialogCustom(
                  //   context,
                  //   title: "Do you want to add this item?",
                  //   dialogType: DialogType.DELETE,
                  //   onAccept: (contexts) {
                  //
                  //   },
                  // );
                },
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

}
