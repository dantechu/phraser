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
/// - Pro notifications: IDs 2000-2999 (managed by custom notification settings)
///   - Morning: 2000-2249 (250 slots)
///   - Afternoon: 2250-2499 (250 slots) 
///   - Evening: 2500-2749 (250 slots)
///   - Midnight: 2750-2999 (250 slots)
/// - Test notifications: ID 99999 (for permission testing)
/// 
/// When saving free notification settings, only free notifications (1000-1999) are cancelled
/// and rescheduled, leaving pro notifications (2000-2999) completely unaffected.
class NotificationIdRanges {
  static const int freeNotificationStart = 1000;
  static const int freeNotificationEnd = 1999;
  static const int proNotificationStart = 2000;
  static const int proNotificationEnd = 2999;
  
  // Pro notification sub-ranges for different time periods
  static const int proMorningStart = 2000;
  static const int proMorningEnd = 2249;
  static const int proAfternoonStart = 2250;
  static const int proAfternoonEnd = 2499;
  static const int proEveningStart = 2500;
  static const int proEveningEnd = 2749;
  static const int proMidnightStart = 2750;
  static const int proMidnightEnd = 2999;
  
  static const int testNotificationId = 99999;
  
  /// Get ID range for specific notification type
  static Map<String, int> getIdRangeFor(CustomNotificationType type) {
    switch (type) {
      case CustomNotificationType.morning:
        return {'start': proMorningStart, 'end': proMorningEnd};
      case CustomNotificationType.afternoon:
        return {'start': proAfternoonStart, 'end': proAfternoonEnd};
      case CustomNotificationType.evening:
        return {'start': proEveningStart, 'end': proEveningEnd};
      case CustomNotificationType.midnight:
        return {'start': proMidnightStart, 'end': proMidnightEnd};
    }
  }
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

  /// Schedule pro/custom notifications for all time periods (uses ID range 2000-2999)
  Future<void> reScheduleProNotifications({CustomNotificationsModel? customNotifications}) async {
    debugPrint('Starting pro notification scheduling...');
    
    // Cancel only existing pro notifications first
    await cancelProNotifications();
    
    if (customNotifications == null || customNotifications.notificationsList.isEmpty) {
      debugPrint('No custom notifications provided');
      return;
    }
    
    // Schedule notifications for each configured time period
    await Future.forEach(customNotifications.notificationsList, (SingleCustomNotificationModel notification) async {
      if (notification.notificationType != null) {
        final notificationType = _getCustomNotificationType(notification.notificationType!);
        if (notificationType != null) {
          await _scheduleNotificationForTimePeriod(notification, notificationType);
        }
      }
    });
    
    debugPrint('Pro notification scheduling completed');
  }
  
  /// Schedule notifications for a specific time period (morning, afternoon, evening, midnight)
  Future<void> _scheduleNotificationForTimePeriod(
    SingleCustomNotificationModel notification, 
    CustomNotificationType timePeriod
  ) async {
    try {
      debugPrint('Scheduling ${timePeriod.name} notifications...');
      
      // Get phrasers for the selected categories
      List<Phraser> availablePhrasers = await _getPhrrasersForCategories(
        notification.notificationCategories ?? []
      );
      
      if (availablePhrasers.isEmpty) {
        debugPrint('No phrasers found for ${timePeriod.name} notifications');
        return;
      }
      
      // Parse notification times
      final startTime = TimeOfDay(
        hour: int.parse(notification.startAt!.split(':')[0]),
        minute: int.parse(notification.startAt!.split(':')[1])
      );
      
      final endTime = TimeOfDay(
        hour: int.parse(notification.endAt!.split(':')[0]),
        minute: int.parse(notification.endAt!.split(':')[1])
      );
      
      // Generate time intervals
      List<TimeOfDay> timeIntervals = getTimeIntervals(
        startTime, 
        endTime, 
        notification.frequency ?? 1
      );
      
      // Get ID range for this time period
      final idRange = NotificationIdRanges.getIdRangeFor(timePeriod);
      final baseId = idRange['start']!;
      
      // Schedule notifications for each time interval
      for (int i = 0; i < timeIntervals.length; i++) {
        final notificationId = baseId + i;
        
        // Ensure we don't exceed the time period's ID range
        if (notificationId > idRange['end']!) {
          debugPrint('Warning: Exceeded ${timePeriod.name} notification ID range. Skipping notification $i');
          continue;
        }
        
        // Schedule notification for each enabled day
        final enabledDays = notification.notificationDays ?? [];
        await _scheduleNotificationForDays(
          notificationId: notificationId,
          timeOfDay: timeIntervals[i],
          enabledDays: enabledDays,
          availablePhrasers: availablePhrasers,
          timePeriod: timePeriod
        );
      }
      
      debugPrint('Scheduled ${timeIntervals.length} ${timePeriod.name} notifications');
      
    } catch (e) {
      debugPrint('Error scheduling ${timePeriod.name} notifications: $e');
    }
  }
  
  /// Schedule notification for specific days of the week
  Future<void> _scheduleNotificationForDays({
    required int notificationId,
    required TimeOfDay timeOfDay,
    required List<bool> enabledDays,
    required List<Phraser> availablePhrasers,
    required CustomNotificationType timePeriod
  }) async {
    try {
      // Days: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
      for (int dayIndex = 0; dayIndex < enabledDays.length; dayIndex++) {
        if (enabledDays[dayIndex] == true) {
          // Calculate unique ID for each day (base ID + day offset)
          final uniqueId = notificationId + (dayIndex * 35); // 35 = max notifications per day per time period
          
          // Select random phraser
          final Random random = Random();
          final selectedPhraser = availablePhrasers[random.nextInt(availablePhrasers.length)];
          
          // Create payload with phraser information for navigation
          final payloadData = {
            'phraserId': selectedPhraser.phraserId,
            'quote': selectedPhraser.quote,
            'categoryName': selectedPhraser.categoryName,
            'action': 'open_phraser',
            'timePeriod': timePeriod.name,
            'dayIndex': dayIndex
          };
          
          // Calculate next occurrence of this day and time
          final scheduledTime = _calculateNextOccurrence(timeOfDay, dayIndex);
          
          // Schedule the notification
          await _scheduleRepeatingNotification(
            id: uniqueId,
            title: _getNotificationTitle(timePeriod),
            description: selectedPhraser.quote,
            scheduledTime: scheduledTime,
            payload: payloadData
          );
          
          debugPrint('Scheduled ${timePeriod.name} notification for ${_getDayName(dayIndex)} at ${timeOfDay.hour}:${timeOfDay.minute.toString().padLeft(2, '0')} (ID: $uniqueId)');
        }
      }
    } catch (e) {
      debugPrint('Error scheduling notification for days: $e');
    }
  }
  
  /// Get phrasers for selected categories
  Future<List<Phraser>> _getPhrrasersForCategories(List<NotificationCategory> categories) async {
    List<Phraser> allPhrasers = [];
    
    if (categories.isEmpty) {
      // If no categories selected, get all phrasers
      try {
        final database = FloorDB.instance.floorDatabase;
        PhrasersDAO phrasersDAO = database.phraserDAO;
        CategoriesDAO categoriesDAO = database.categoriesDAO;
        
        final allCategories = await categoriesDAO.getAllCategories();
        
        for (final category in allCategories) {
          try {
            final categoryPhrasers = await phrasersDAO.getAllPhrasers(category.categoryName);
            allPhrasers.addAll(categoryPhrasers);
          } catch (e) {
            debugPrint('Error fetching category ${category.categoryName}: $e');
          }
        }
      } catch (e) {
        debugPrint('Error fetching all phrasers: $e');
      }
    } else {
      // Get phrasers for selected categories
      await Future.forEach(categories, (NotificationCategory category) async {
        try {
          final database = FloorDB.instance.floorDatabase;
          PhrasersDAO phrasersDAO = database.phraserDAO;
          final categoryPhrasers = await phrasersDAO.getAllPhrasers(category.name);
          allPhrasers.addAll(categoryPhrasers);
        } catch (e) {
          debugPrint('Error fetching category ${category.name}: $e');
        }
      });
    }
    
    return allPhrasers;
  }
  
  /// Convert string to CustomNotificationType enum
  CustomNotificationType? _getCustomNotificationType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'morning':
        return CustomNotificationType.morning;
      case 'afternoon':
        return CustomNotificationType.afternoon;
      case 'evening':
        return CustomNotificationType.evening;
      case 'midnight':
        return CustomNotificationType.midnight;
      default:
        return null;
    }
  }
  
  /// Calculate next occurrence of specified day and time
  DateTime _calculateNextOccurrence(TimeOfDay timeOfDay, int dayIndex) {
    final now = DateTime.now();
    final today = now.weekday; // 1 = Monday, 7 = Sunday
    
    // Convert dayIndex (0-6, Monday-Sunday) to DateTime weekday (1-7, Monday-Sunday)
    final targetWeekday = dayIndex + 1;
    
    var daysUntilTarget = targetWeekday - today;
    if (daysUntilTarget <= 0) {
      daysUntilTarget += 7; // Next week
    }
    
    final targetDate = now.add(Duration(days: daysUntilTarget));
    final scheduledDateTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    
    return scheduledDateTime;
  }
  
  /// Get notification title based on time period
  String _getNotificationTitle(CustomNotificationType timePeriod) {
    switch (timePeriod) {
      case CustomNotificationType.morning:
        return 'Good Morning! 🌅';
      case CustomNotificationType.afternoon:
        return 'Afternoon Motivation! ☀️';
      case CustomNotificationType.evening:
        return 'Evening Inspiration! 🌆';
      case CustomNotificationType.midnight:
        return 'Midnight Reflection! 🌙';
    }
  }
  
  /// Get day name from index
  String _getDayName(int dayIndex) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayIndex];
  }
  
  /// Schedule repeating notification
  Future<void> _scheduleRepeatingNotification({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload,
    bool isWeekly = true
  }) async {
    
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '$id',
      title,
      importance: Importance.max,
      ticker: 'Phraser',
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(description),
      category: AndroidNotificationCategory.message,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Configure timezone first
    await _configureLocalTimeZone();
    
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        description,
        tzScheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: payload != null ? jsonEncode(payload) : '',
        matchDateTimeComponents: isWeekly ? DateTimeComponents.dayOfWeekAndTime : DateTimeComponents.time,
      );
      debugPrint('Repeating notification scheduled successfully (id: $id): $title at $scheduledTime');
    } catch (e) {
      debugPrint('Error scheduling repeating notification: $e');
    }
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

  /// Cancel notifications for a specific time period
  Future<void> cancelNotificationsForTimePeriod(CustomNotificationType timePeriod) async {
    final idRange = NotificationIdRanges.getIdRangeFor(timePeriod);
    final startId = idRange['start']!;
    final endId = idRange['end']!;
    
    debugPrint('Cancelling ${timePeriod.name} notifications (ID: $startId-$endId)');
    
    try {
      // Get all pending notifications
      final List<PendingNotificationRequest> pendingNotifications = 
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      
      // Cancel notifications in the specified range
      for (final notification in pendingNotifications) {
        if (notification.id >= startId && notification.id <= endId) {
          await flutterLocalNotificationsPlugin.cancel(notification.id);
          debugPrint('Cancelled ${timePeriod.name} notification ID: ${notification.id}');
        }
      }
      
      debugPrint('Successfully cancelled all ${timePeriod.name} notifications');
    } catch (e) {
      debugPrint('Error cancelling ${timePeriod.name} notifications: $e');
      // Fallback: cancel by specific ID range
      for (int id = startId; id <= endId; id++) {
        try {
          await flutterLocalNotificationsPlugin.cancel(id);
        } catch (cancelError) {
          // Ignore individual cancel errors
        }
      }
    }
  }

  /// Cancel morning notifications only
  Future<void> cancelMorningNotifications() async {
    await cancelNotificationsForTimePeriod(CustomNotificationType.morning);
  }

  /// Cancel afternoon notifications only
  Future<void> cancelAfternoonNotifications() async {
    await cancelNotificationsForTimePeriod(CustomNotificationType.afternoon);
  }

  /// Cancel evening notifications only
  Future<void> cancelEveningNotifications() async {
    await cancelNotificationsForTimePeriod(CustomNotificationType.evening);
  }

  /// Cancel midnight notifications only
  Future<void> cancelMidnightNotifications() async {
    await cancelNotificationsForTimePeriod(CustomNotificationType.midnight);
  }

  /// Get all the notification the are in pending state and not delivered
  Future<void> checkPendingNotifications() async {
    final available = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint('****************************** Total pending: ${available.length}');
    
    int freeCount = 0;
    int morningCount = 0;
    int afternoonCount = 0;
    int eveningCount = 0;
    int midnightCount = 0;
    int otherCount = 0;
    
    for (final notification in available) {
      if (notification.id >= NotificationIdRanges.freeNotificationStart && 
          notification.id <= NotificationIdRanges.freeNotificationEnd) {
        freeCount++;
      } else if (notification.id >= NotificationIdRanges.proMorningStart && 
                 notification.id <= NotificationIdRanges.proMorningEnd) {
        morningCount++;
      } else if (notification.id >= NotificationIdRanges.proAfternoonStart && 
                 notification.id <= NotificationIdRanges.proAfternoonEnd) {
        afternoonCount++;
      } else if (notification.id >= NotificationIdRanges.proEveningStart && 
                 notification.id <= NotificationIdRanges.proEveningEnd) {
        eveningCount++;
      } else if (notification.id >= NotificationIdRanges.proMidnightStart && 
                 notification.id <= NotificationIdRanges.proMidnightEnd) {
        midnightCount++;
      } else {
        otherCount++;
      }
    }
    
    debugPrint('Free: $freeCount, Morning: $morningCount, Afternoon: $afternoonCount, Evening: $eveningCount, Midnight: $midnightCount, Other: $otherCount');
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
        'Test Notification - Close App!',
        'Tap me to test cold start navigation! (Close the app completely first)',
        platformChannelSpecifics,
        payload: jsonEncode(testPayload),
      );
      
      debugPrint('Test notification sent successfully - Close the app completely and tap the notification to test cold start');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  /// Handle cold start notification (when app was launched from notification)
  /// Static method so it can be called from anywhere
  static void handleColdStartNotification(String? payload) {
    debugPrint('Handling cold start notification with payload: $payload');
    _handleNotificationPayload(payload);
  }

  /// Common method to handle notification payload from both warm and cold starts
  static void _handleNotificationPayload(String? payload) {
    try {
      if (payload != null && payload.isNotEmpty) {
        final payloadData = jsonDecode(payload);
        
        if (payloadData['action'] == 'open_phraser') {
          final phraserId = payloadData['phraserId'] as String;
          final quote = payloadData['quote'] as String;
          final categoryName = payloadData['categoryName'] as String;
          
          debugPrint('Opening phraser: $phraserId from category: $categoryName');
          
          // Navigate to the phraser screen with specific phraser data
          _navigateToSpecificPhraser(phraserId, quote, categoryName);
          return;
        }
      }
      
      // If no valid payload, navigate to main screen
      debugPrint('No valid payload found, navigating to main screen');
      _navigateToMainScreen();
      
    } catch (e) {
      debugPrint('Error handling notification payload: $e');
      // Fallback: navigate to main screen
      _navigateToMainScreen();
    }
  }

  /// Navigate to the main phraser screen
  static void _navigateToMainScreen() {
    try {
      // Use Get.toNamed to navigate to the main phraser screen
      // This will work from any state of the app
      Get.offAllNamed(RouteHelper.phraserScreen);
    } catch (e) {
      debugPrint('Error navigating to main screen: $e');
    }
  }

  /// Navigate to specific phraser by finding its position in the current list
  static void _navigateToSpecificPhraser(String phraserId, String quote, String categoryName) async {
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
  static int _findPhraserPosition(List<Phraser> phrasersList, String phraserId) {
    for (int i = 0; i < phrasersList.length; i++) {
      if (phrasersList[i].phraserId == phraserId) {
        return i;
      }
    }
    return -1;
  }

  /// Search for phraser in database and navigate
  static Future<void> _searchAndNavigateToPhraserFromDatabase(String phraserId, String categoryName) async {
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
}

void onLocalNotificationSelect(NotificationResponse notificationResponse) {
  /// Handle notification tap - navigate to specific phraser
  debugPrint('Notification tapped with payload: ${notificationResponse.payload}');
  NotificationHelper._handleNotificationPayload(notificationResponse.payload);
}