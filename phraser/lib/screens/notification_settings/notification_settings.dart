import 'dart:io';

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
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
        title: Text('Notifications Settings'),
        actions: [
          TextButton(onPressed: (){
            _savePremiumSettings();
          }, child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 18),))
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NotificationTitleWidget(title: 'Morning'),
            SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.morning.name,),
            const NotificationTitleWidget(title: 'Afternoon'),
            SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.afternoon.name,),
            const NotificationTitleWidget(title: 'Evening'),
            SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.evening.name,),
            const NotificationTitleWidget(title: 'Midnight'),
            SpecificTimeNotificationWidget(notificationKey: CustomNotificationType.midnight.name,),
            // Container(
            //     width: MediaQuery.of(context).size.width,
            //     height: 45.0,
            //     margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 70.0),
            //     child: ElevatedButton(
            //         onPressed: () async {
            //           if(Preferences.instance.isFirstOpen) {
            //             Preferences.instance.isFirstOpen = false;
            //           }
            //
            //
            //           String startHour = _startTime.hour.toInt() < 10 ? '0${_startTime.hour}' : _startTime.hour.toString();
            //           String startMinute = _startTime.minute.toInt() < 10 ? '0${_startTime.minute}' : _startTime.minute.toString();
            //           String endtHour = _endTime.hour.toInt() < 10 ? '0${_endTime.hour}' : _endTime.hour.toString();
            //           String endMinute = _endTime.minute.toInt() < 10 ? '0${_endTime.minute}' : _endTime.minute.toString();
            //           NotificationsModel model =
            //           NotificationsModel(
            //               startAt: '$startHour:$startMinute',
            //               endAt: '$endtHour:$endMinute',
            //               frequency: _frequency.toInt(), notificationData: ['notification 1','notification 2', 'notification 2']);
            //           NotificationConfigService.instance.notificationDetails = model;
            //           final permissionStatus = await  Permission.notification.status;
            //             if ( permissionStatus != PermissionStatus.granted) {
            //              await  Permission.notification.request();
            //             }
            //
            //           await  NotificationHelper.instance.reScheduleNotifications();
            //
            //           if(widget.willPop) {
            //             Navigator.pop(context);
            //           } else {
            //             Get.offAllNamed(RouteHelper.phraserScreen);
            //           }
            //         },
            //         child: const Text(
            //           'Save',
            //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            //         ))),
          ],
        ),
      ),
    );
  }


  Future<void> _savePremiumSettings() async {
    await NotificationHelper.instance.cancelAllNotifications();
    Fluttertoast.showToast(msg: 'Notification settings saved!');
    final currentDay = DateTime.now().weekday;
    CustomNotificationsModel notificationsData = CustomNotificationsModel.fromRawJson(Preferences.instance.customNotifications);



    await Future.forEach(notificationsData.notificationsList, (final SingleCustomNotificationModel notificationTime) async {

                 debugPrint('---> Scheduling notifications for: ${notificationTime.notificationType}');
                TimeOfDay _startTime = _convertStringToTimeOfDay(notificationTime.startAt.toString());
                TimeOfDay _endTime = _convertStringToTimeOfDay(notificationTime.endAt.toString());


                String startHour = _startTime.hour.toInt() < 10 ? '0${_startTime.hour}' : _startTime.hour.toString();
                String startMinute = _startTime.minute.toInt() < 10 ? '0${_startTime.minute}' : _startTime.minute.toString();
                String endtHour = _endTime.hour.toInt() < 10 ? '0${_endTime.hour}' : _endTime.hour.toString();
                String endMinute = _endTime.minute.toInt() < 10 ? '0${_endTime.minute}' : _endTime.minute.toString();
                NotificationsModel model =
                NotificationsModel(
                    startAt: '$startHour:$startMinute',
                    endAt: '$endtHour:$endMinute',
                    frequency: notificationTime.frequency!.toInt(), notificationData: ['notification 1','notification 2', 'notification 2']);
                NotificationConfigService.instance.notificationDetails = model;
                await  NotificationHelper.instance.reScheduleNotifications(categoriesList: notificationTime.notificationCategories);
    });

  }


  TimeOfDay _convertStringToTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }
}