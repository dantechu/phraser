import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:phraser/floor_db/categories_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/screens/notification_settings/model/custom_notifications_model.dart';
import 'package:phraser/screens/notification_settings/service/notifications_service.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';
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
      
      // Schedule with free notification ID
      scheduleLocalNotification(
        id: notificationId, 
        title: 'Reminder', 
        description: nCategoryList[index].quote, 
        duration: duration
      );

      debugPrint('************************* [Free ID: $notificationId] ${nCategoryList[index].quote}');
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
  Future<void> scheduleLocalNotification({required int id,
    required String title,
    required String description,
    required Duration duration}) async {

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
        payload: '',
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
          payload: ''
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

}

void onLocalNotificationSelect(NotificationResponse payload) {
  /// Whenever a notification gets called this function with be executed
  /// And this function will have the same payload that was provided to the notification
  /// Usually we provide payload data in the form of Map<String, dynamic> and add as much
  /// details as possible, so we can handle notification here according to those details
}