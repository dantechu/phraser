import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:phraser/floor_db/categories_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/screens/notification_settings/model/custom_notifications_model.dart';
import 'package:phraser/screens/notification_settings/service/notifications_service.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Notification ID ranges to separate free and pro notifications
/// 
/// This system ensures that free and pro notifications can be managed independently:
/// - Free notifications: IDs 1000-1999 (managed by FreeNotificationSettingsScreen)
/// - Pro notifications: IDs 2000-2999 (for future pro features)
/// - Test notifications: ID 99999 (for permission testing)
/// 
/// When saving free notification settings, only free notifications (1000-1999) are cancelled
/// and rescheduled, leaving pro notifications (2000-2999) completely unaffected.
class NotificationIdRanges {
  static const int freeNotificationStart = 1000;
  static const int freeNotificationEnd = 1999;
  static const int proNotificationStart = 2000;
  static const int proNotificationEnd = 2999;
  static const int testNotificationId = 99999;
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

/// A singleton class to handle local notifications in the app
class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._();
  static NotificationHelper get instance => _instance;
  NotificationHelper._();

  /// Show a simple notification without any delay
  /// This is just a sample notifications and parameters in this notifications
  /// can be set to dynamically passed when function called
  Future<void> showLocalNotification() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails,  iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),);
    debugPrint('******************** Trying to show notification');
    await flutterLocalNotificationsPlugin.show(1, 'Tuuli test notification',
        'whooo! Test notification displayed successfully', notificationDetails,
        payload: '{}');
  }


  /// Fetch local timezone of the user to schedule notifications accordingly
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // The timezone package automatically uses the device's local timezone
  }
  
  
  /// Schedule free notifications only (uses ID range 1000-1999)
  Future<void> reScheduleFreeNotifications({List<NotificationCategory>? categoriesList}) async {
    // Cancel only existing free notifications first
    await cancelFreeNotifications();

    List<Phraser> nCategoryList = [];
    if(categoriesList != null && categoriesList.isNotEmpty) {
      await Future.forEach (categoriesList, (final NotificationCategory notificationCategory) async {
        try {
          final database = FloorDB.instance.floorDatabase;
          PhrasersDAO phrasersDAO = database.phraserDAO;
          final categoryPhrasers = await phrasersDAO.getAllPhrasers(notificationCategory.name);
          nCategoryList = nCategoryList + categoryPhrasers;
        } catch (e) {
          debugPrint('---> Error in fetching category: ${notificationCategory.name}');
        }
      });
    } else {
      // If no categories provided, get all available categories and fetch their phrasers
      try {
        final database = FloorDB.instance.floorDatabase;
        PhrasersDAO phrasersDAO = database.phraserDAO;
        CategoriesDAO categoriesDAO = database.categoriesDAO;
        
        // Get all categories first
        final allCategories = await categoriesDAO.getAllCategories();
        
        // Fetch phrasers for each category
        for (final category in allCategories) {
          try {
            final categoryPhrasers = await phrasersDAO.getAllPhrasers(category.categoryName);
            nCategoryList = nCategoryList + categoryPhrasers;
          } catch (e) {
            debugPrint('---> Error in fetching category ${category.categoryName}: $e');
          }
        }
      } catch (e) {
        debugPrint('---> Error in fetching all phrasers: $e');
        return;
      }
    }

    if(nCategoryList.isEmpty) {
      debugPrint('---> No phrasers found for notifications');
      return;
    }


    final notificationDetails = NotificationConfigService.instance.notificationDetails;
    final startTime = TimeOfDay(hour: int.parse(notificationDetails!.startAt.split(':')[0]),
        minute: int.parse(notificationDetails.startAt.split(':')[1]));

    final endTime = TimeOfDay(hour: int.parse(notificationDetails.endAt.split(':')[0]),
        minute: int.parse(notificationDetails.endAt.split(':')[1]));

    List<TimeOfDay> timeOfDayList = getTimeIntervals(
        startTime, endTime, notificationDetails.frequency);

    for(int i = 0; i<timeOfDayList.length; i++) {
      // Use free notification ID range (1000-1999)
      final notificationId = NotificationIdRanges.freeNotificationStart + i;
      
      // Ensure we don't exceed the free notification range
      if (notificationId > NotificationIdRanges.freeNotificationEnd) {
        debugPrint('Warning: Exceeded free notification ID range. Skipping notification $i');
        continue;
      }
      
      final timingHour = timeOfDayList[i].hour;
      final timingMin = timeOfDayList[i].minute;
      Duration duration = DateTime(
        DateTime
            .now()
            .year,
        DateTime
            .now()
            .month,
        DateTime
            .now()
            .day,
        timingHour,
        timingMin,
      ).difference(DateTime.now());

      if (DateTime
          .now()
          .hour > timingHour) {
        duration = DateTime(
          DateTime
              .now()
              .year,
          DateTime
              .now()
              .month,
          DateTime
              .now()
              .day ,
          timingHour,
          timingMin,
        ).difference(DateTime.now());
      } else if (DateTime
          .now()
          .hour == timingHour &&
          DateTime
              .now()
              .minute >= timingMin) {
        duration = DateTime(
          DateTime
              .now()
              .year,
          DateTime
              .now()
              .month,
          DateTime
              .now()
              .day ,
          timingHour,
          timingMin,
        ).difference(DateTime.now());
      }

      Random random = Random();
      debugPrint('************************* nCategoryLIst length: ${nCategoryList.length}');
      int index = random.nextInt(nCategoryList.length);
      final selectedPhraser = nCategoryList[index];
      
      // Create payload with phraser information for navigation
      final payloadData = {
        'phraserId': selectedPhraser.phraserId,
        'quote': selectedPhraser.quote,
        'categoryName': selectedPhraser.categoryName,
        'action': 'open_phraser'
      };
      
      // Schedule with free notification ID
      scheduleLocalNotification(
        id: notificationId, 
        title: 'Daily Motivation', 
        description: selectedPhraser.quote, 
        duration: duration,
        payload: payloadData
      );

      debugPrint('************************* [Free ID: $notificationId] ${selectedPhraser.phraserId}: ${selectedPhraser.quote}');
    }
  }

  /// Legacy method for backward compatibility - now calls reScheduleFreeNotifications
  @Deprecated('Use reScheduleFreeNotifications for free notifications or reScheduleProNotifications for pro notifications')
  Future<void> reScheduleNotifications({List<NotificationCategory>? categoriesList}) async {
    debugPrint('Warning: reScheduleNotifications is deprecated. Use reScheduleFreeNotifications instead.');
    await reScheduleFreeNotifications(categoriesList: categoriesList);
  }

  /// Future method for pro notifications (uses ID range 2000-2999)
  Future<void> reScheduleProNotifications({List<NotificationCategory>? categoriesList}) async {
    // Cancel only existing pro notifications first
    await cancelProNotifications();
    
    // TODO: Implement pro notification scheduling logic
    // This will be implemented when pro notifications feature is added
    debugPrint('Pro notification scheduling - To be implemented');
    
    // For now, just log that this method was called
    debugPrint('reScheduleProNotifications called with ${categoriesList?.length ?? 0} categories');
  }

    List<TimeOfDay> getTimeIntervals(TimeOfDay startTime, TimeOfDay endTime, int n) {
      // Calculate the total number of minutes between the start and end times
      int totalMinutes = (endTime.hour * 60 + endTime.minute) -
          (startTime.hour * 60 + startTime.minute);

      // Calculate the interval between each time
      int interval = totalMinutes ~/ (n + 1);

      // Calculate the list of times
      List<TimeOfDay> timeIntervals = [];

      for (int i = 1; i <= n; i++) {
        // Calculate the minutes from the start time
        int minutes = startTime.minute + (interval * i);

        // Calculate the hour and minute values
        int hours = startTime.hour + (minutes ~/ 60);
        minutes = minutes % 60;

        // Add the new TimeOfDay instance to the list
        timeIntervals.add(TimeOfDay(hour: hours, minute: minutes));
      }

      return timeIntervals;
    }


  /// Schedules a local notification according to the given duration
  /// /// This is just a sample notifications and parameters in this notifications
  /// can be set to dynamically passed when function called
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String description,
    required Duration duration,
    Map<String, dynamic>? payload}) async {

    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '$id',
      title,

      importance: Importance.max,
      ticker: 'Blessed',
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(description),
      category: AndroidNotificationCategory.message,
    );

    /// Customize android and iOS notification details if required
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    // Configure timezone first
    await _configureLocalTimeZone();
    
    final scheduledTime = tz.TZDateTime.now(tz.local).add(duration);
    debugPrint('--------------> Notification scheduled at time: $scheduledTime');
    
    /// scheduled notification function
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        description,
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: payload != null ? jsonEncode(payload) : '',
      );
      debugPrint('Notification scheduled successfully (id: $id): $title');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      // Fallback to immediate notification if scheduling fails
      try {
        await flutterLocalNotificationsPlugin.show(
          id,
          title,
          description,
          platformChannelSpecifics,
          payload: payload != null ? jsonEncode(payload) : ''
        );
        debugPrint('Fallback: Notification shown immediately (id: $id): $title');
      } catch (showError) {
        debugPrint('Error showing fallback notification: $showError');
      }
    }
  }

  /// Initialize the basic settings of a notification when app starts
  /// These details can be modified when each notification is displayed or scheduled
  Future<void> initializeLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onLocalNotificationSelect,
        onDidReceiveBackgroundNotificationResponse:
        onLocalNotificationSelect);
    _configureLocalTimeZone();
  }

  /// A function to cancel all the current notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel only free notifications (ID range 1000-1999)
  Future<void> cancelFreeNotifications() async {
    debugPrint('Cancelling free notifications (ID: ${NotificationIdRanges.freeNotificationStart}-${NotificationIdRanges.freeNotificationEnd})');
    
    try {
      // Get all pending notifications
      final List<PendingNotificationRequest> pendingNotifications = 
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      
      // Cancel only free notifications
      for (final notification in pendingNotifications) {
        if (notification.id >= NotificationIdRanges.freeNotificationStart && 
            notification.id <= NotificationIdRanges.freeNotificationEnd) {
          await flutterLocalNotificationsPlugin.cancel(notification.id);
          debugPrint('Cancelled free notification ID: ${notification.id}');
        }
      }
      
      debugPrint('Successfully cancelled all free notifications');
    } catch (e) {
      debugPrint('Error cancelling free notifications: $e');
      // Fallback: cancel by specific ID range (less efficient but more reliable)
      for (int id = NotificationIdRanges.freeNotificationStart; 
           id <= NotificationIdRanges.freeNotificationEnd; 
           id++) {
        try {
          await flutterLocalNotificationsPlugin.cancel(id);
        } catch (cancelError) {
          // Ignore individual cancel errors
        }
      }
    }
  }

  /// Cancel only pro notifications (ID range 2000-2999)
  Future<void> cancelProNotifications() async {
    debugPrint('Cancelling pro notifications (ID: ${NotificationIdRanges.proNotificationStart}-${NotificationIdRanges.proNotificationEnd})');
    
    try {
      // Get all pending notifications
      final List<PendingNotificationRequest> pendingNotifications = 
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      
      // Cancel only pro notifications
      for (final notification in pendingNotifications) {
        if (notification.id >= NotificationIdRanges.proNotificationStart && 
            notification.id <= NotificationIdRanges.proNotificationEnd) {
          await flutterLocalNotificationsPlugin.cancel(notification.id);
          debugPrint('Cancelled pro notification ID: ${notification.id}');
        }
      }
      
      debugPrint('Successfully cancelled all pro notifications');
    } catch (e) {
      debugPrint('Error cancelling pro notifications: $e');
      // Fallback: cancel by specific ID range
      for (int id = NotificationIdRanges.proNotificationStart; 
           id <= NotificationIdRanges.proNotificationEnd; 
           id++) {
        try {
          await flutterLocalNotificationsPlugin.cancel(id);
        } catch (cancelError) {
          // Ignore individual cancel errors
        }
      }
    }
  }

  /// Get all the notification the are in pending state and not delivered
  Future<void> checkPendingNotifications() async {
    final available = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint('****************************** Total pending: ${available.length}');
    
    int freeCount = 0;
    int proCount = 0;
    int otherCount = 0;
    
    for (final notification in available) {
      if (notification.id >= NotificationIdRanges.freeNotificationStart && 
          notification.id <= NotificationIdRanges.freeNotificationEnd) {
        freeCount++;
      } else if (notification.id >= NotificationIdRanges.proNotificationStart && 
                 notification.id <= NotificationIdRanges.proNotificationEnd) {
        proCount++;
      } else {
        otherCount++;
      }
    }
    
    debugPrint('Free notifications: $freeCount, Pro notifications: $proCount, Other: $otherCount');
  }

  /// Get pending notifications by type
  Future<List<PendingNotificationRequest>> getPendingFreeNotifications() async {
    final allPending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return allPending.where((notification) => 
        notification.id >= NotificationIdRanges.freeNotificationStart && 
        notification.id <= NotificationIdRanges.freeNotificationEnd
    ).toList();
  }

  /// Get pending pro notifications
  Future<List<PendingNotificationRequest>> getPendingProNotifications() async {
    final allPending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return allPending.where((notification) => 
        notification.id >= NotificationIdRanges.proNotificationStart && 
        notification.id <= NotificationIdRanges.proNotificationEnd
    ).toList();
  }

  /// Test notification with payload to verify navigation works
  Future<void> sendTestNotificationWithNavigation() async {
    debugPrint('Sending test notification with navigation payload');
    
    try {
      // Create a test payload
      final testPayload = {
        'phraserId': 'test_phraser_123',
        'quote': 'This is a test notification to verify navigation works properly!',
        'categoryName': 'Test Category',
        'action': 'open_phraser'
      };
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel', 'Test Channel',
        importance: Importance.high,
        priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails, 
        iOS: iosDetails,
      );
      
      await flutterLocalNotificationsPlugin.show(
        NotificationIdRanges.testNotificationId,
        'Test Notification',
        'Tap me to test navigation to specific phraser!',
        platformChannelSpecifics,
        payload: jsonEncode(testPayload),
      );
      
      debugPrint('Test notification sent successfully');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

}

void onLocalNotificationSelect(NotificationResponse notificationResponse) {
  /// Handle notification tap - navigate to specific phraser
  debugPrint('Notification tapped with payload: ${notificationResponse.payload}');
  
  try {
    if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
      final payloadData = jsonDecode(notificationResponse.payload!);
      
      if (payloadData['action'] == 'open_phraser') {
        final phraserId = payloadData['phraserId'] as String;
        final quote = payloadData['quote'] as String;
        final categoryName = payloadData['categoryName'] as String;
        
        debugPrint('Opening phraser: $phraserId from category: $categoryName');
        
        // Navigate to the phraser screen with specific phraser data
        _navigateToSpecificPhraser(phraserId, quote, categoryName);
      }
    }
  } catch (e) {
    debugPrint('Error handling notification payload: $e');
    // Fallback: navigate to main screen
    _navigateToMainScreen();
  }
}

/// Navigate to the main phraser screen
void _navigateToMainScreen() {
  try {
    // Use Get.toNamed to navigate to the main phraser screen
    // This will work from any state of the app
    Get.offAllNamed(RouteHelper.phraserScreen);
  } catch (e) {
    debugPrint('Error navigating to main screen: $e');
  }
}

/// Navigate to specific phraser by finding its position in the current list
void _navigateToSpecificPhraser(String phraserId, String quote, String categoryName) async {
  try {
    debugPrint('Navigating to phraser: $phraserId from category: $categoryName');
    
    // Get the current data repository
    final dataRepository = DataRepository();
    final currentList = dataRepository.currentPhrasersList;
    
    // Try to find the phraser in the current list first
    int phraserPosition = _findPhraserPosition(currentList, phraserId);
    
    if (phraserPosition != -1) {
      debugPrint('Found phraser at position: $phraserPosition in current category');
      Preferences.instance.currentPhraserPosition = phraserPosition;
      Get.offAllNamed(RouteHelper.phraserScreen);
      return;
    }
    
    // If not found in current category, try to load it from database
    debugPrint('Phraser not found in current category, searching in database...');
    await _searchAndNavigateToPhraserFromDatabase(phraserId, categoryName);
    
  } catch (e) {
    debugPrint('Error navigating to specific phraser: $e');
    _navigateToMainScreen();
  }
}

/// Find phraser position in the given list
int _findPhraserPosition(List<Phraser> phrasersList, String phraserId) {
  for (int i = 0; i < phrasersList.length; i++) {
    if (phrasersList[i].phraserId == phraserId) {
      return i;
    }
  }
  return -1;
}

/// Search for phraser in database and navigate
Future<void> _searchAndNavigateToPhraserFromDatabase(String phraserId, String categoryName) async {
  try {
    final database = FloorDB.instance.floorDatabase;
    final phrasersDAO = database.phraserDAO;
    
    // Get phrasers from the specific category
    final categoryPhrasers = await phrasersDAO.getAllPhrasers(categoryName);
    
    if (categoryPhrasers.isNotEmpty) {
      // Find the specific phraser in this category
      int phraserPosition = _findPhraserPosition(categoryPhrasers, phraserId);
      
      if (phraserPosition != -1) {
        debugPrint('Found phraser in database at position: $phraserPosition');
        
        // Update the current category and phraser list
        DataRepository().currentPhrasersList = categoryPhrasers;
        Preferences.instance.savedCategoryName = categoryName;
        Preferences.instance.currentPhraserPosition = phraserPosition;
        
        debugPrint('Updated category to: $categoryName and position to: $phraserPosition');
        
        // Navigate to the phraser screen
        Get.offAllNamed(RouteHelper.phraserScreen);
        return;
      }
    }
    
    // If still not found, navigate to main screen
    debugPrint('Phraser not found in database, navigating to main screen');
    _navigateToMainScreen();
    
  } catch (e) {
    debugPrint('Error searching phraser in database: $e');
    _navigateToMainScreen();
  }
}