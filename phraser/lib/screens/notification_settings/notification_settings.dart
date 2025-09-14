import 'dart:io';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/screens/notification_settings/model/custom_notifications_model.dart';
import 'package:phraser/screens/notification_settings/widgets/days_of_week.dart';
import 'package:phraser/screens/notification_settings/model/notification_model.dart';
import 'package:phraser/screens/notification_settings/notification_helper.dart';
import 'package:phraser/screens/notification_settings/service/notifications_service.dart';
import 'package:phraser/screens/notification_settings/widgets/notification_title_widget.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';

import 'widgets/specific_time_notification_widget.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key, required this.willPop}) : super(key: key);

  final bool willPop;

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {





  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Theme.of(context).primaryColor,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: const Text(
            'Custom Reminders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: _savePremiumSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header description
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set up personalized reminder schedules for different times of day. Choose frequency, days, and categories for each period.',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const NotificationTitleWidget(title: 'Morning'),
                SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.morning.name),
                
                const NotificationTitleWidget(title: 'Afternoon'),
                SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.afternoon.name),
                
                const NotificationTitleWidget(title: 'Evening'),
                SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.evening.name),
                
                const NotificationTitleWidget(title: 'Midnight'),
                SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.midnight.name),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _savePremiumSettings() async {
    try {
      debugPrint('Starting custom notification settings save...');
      
      // Get saved custom notification settings
      CustomNotificationsModel? customNotifications;
      
      try {
        customNotifications = CustomNotificationsModel.fromRawJson(Preferences.instance.customNotifications);
      } catch (e) {
        debugPrint('No custom notifications found or error parsing: $e');
        // Try to get from the new notification service
        customNotifications = NotificationConfigService.instance.customNotificationDetails;
      }
      
      if (customNotifications == null || customNotifications.notificationsList.isEmpty) {
        debugPrint('No custom notification settings to save');
        Fluttertoast.showToast(msg: 'No notification settings configured yet!');
        return;
      }

      // Use our new professional notification system
      await NotificationHelper.instance.reScheduleProNotifications(
        customNotifications: customNotifications
      );

      // Save to both storage systems for compatibility
      NotificationConfigService.instance.customNotificationDetails = customNotifications;
      Preferences.instance.customNotifications = customNotifications.toRawJson();

      // Show success message
      Fluttertoast.showToast(msg: 'Custom notification settings saved successfully!');
      debugPrint('Custom notification settings saved and scheduled successfully');

      // Navigate back if needed
      if (widget.willPop) {
        Navigator.pop(context);
      } else {
        Get.offAllNamed(RouteHelper.phraserScreen);
      }
      
    } catch (e) {
      debugPrint('Error saving custom notification settings: $e');
      Fluttertoast.showToast(msg: 'Error saving settings: $e');
    }
  }


  TimeOfDay _convertStringToTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }
}