import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:phraser/floor_db/categories_dao.dart';
import 'package:phraser/floor_db/current_phraser_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/screens/notification_settings/model/custom_notifications_model.dart';
import 'package:phraser/screens/notification_settings/service/notifications_service.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

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
        sound:  RawResourceAndroidNotificationSound('message_received'),
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
  
  
  Future<void> reScheduleNotifications({List<NotificationCategory>? categoriesList}) async {

    List<Phraser> nCategoryList = [];
    if(categoriesList != null) {
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
      return;
    }


    if(nCategoryList.isEmpty) {
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
       scheduleLocalNotification(id: i, title: 'Reminder', description: '${nCategoryList[index].quote}', duration: duration);

      debugPrint('************************* [$i] ${nCategoryList[index].quote}');
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
      sound: const RawResourceAndroidNotificationSound('message_received'),
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(description),
      category: AndroidNotificationCategory.message,
    );

    /// Customize android and iOS notification details if required
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(sound: 'message_received.mp3'),
    );

    final time = tz.TZDateTime.now(tz.local).add(duration);

    debugPrint('--------------> Notification scheduled at time: $time');
    /// scheduled notification function
    // await flutterLocalNotificationsPlugin.zonedSchedule(id, title, description,
    //     tz.TZDateTime.now(tz.local).add(duration), platformChannelSpecifics,
    //     uiLocalNotificationDateInterpretation:
    //     UILocalNotificationDateInterpretation.absoluteTime,
    //     androidAllowWhileIdle: true,
    //     matchDateTimeComponents: DateTimeComponents.time,
    //     payload: '');// empty payload right now for tests
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

  /// Get all the notification the are in pending state and not delivered
  Future<void> checkPendingNotifications() async {
    final available = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('****************************** ${available.length} ');
  }

}

void onLocalNotificationSelect(NotificationResponse payload) {
  /// Whenever a notification gets called this function with be executed
  /// And this function will have the same payload that was provided to the notification
  /// Usually we provide payload data in the form of Map<String, dynamic> and add as much
  /// details as possible, so we can handle notification here according to those details
}