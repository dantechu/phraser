import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/screens/notification_settings/model/custom_notifications_model.dart';
import 'package:phraser/screens/notification_settings/notification_categories_screen.dart';
import 'package:phraser/screens/notification_settings/widgets/days_of_week.dart';
import 'package:phraser/screens/notification_settings/model/notification_model.dart';
import 'package:phraser/screens/notification_settings/notification_helper.dart';
import 'package:phraser/screens/notification_settings/service/notifications_service.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';

class SpecificTimeNotificationWidget extends StatefulWidget {
  const SpecificTimeNotificationWidget({Key? key, required this.notificationKey}) : super(key: key);

  final String notificationKey;

  @override
  State<SpecificTimeNotificationWidget> createState() => _SpecificTimeNotificationWidgetState();
}

class _SpecificTimeNotificationWidgetState extends State<SpecificTimeNotificationWidget> {
  TimeOfDay _startTime = TimeOfDay(hour: 5, minute: 0,);
  TimeOfDay _endTime = TimeOfDay(hour: 21, minute: 0);
  double _frequency = 0.0;
  SingleCustomNotificationModel? _notificationsModel;


  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (newTime != null) {
      updateNotificationSettings(startAt: '${newTime.hour}:${newTime.minute}');
      setState(() {
        _startTime = newTime;
      });
    }
  }

  String formatToDoubleDigit(String time) {
    List<String> parts = time.split(':');
    if (parts.length != 2) {
      debugPrint('Invalid time format');
    }

    String hour = parts[0].padLeft(2, '0');
    String minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }

  SingleCustomNotificationModel getNotificationData() {
    final data = Preferences.instance.customNotifications;
    if (data.isEmpty) {
      return SingleCustomNotificationModel(
        startAt: '09:00',
        endAt: '15:00',
        notificationData: [],
        frequency: 0,
        notificationType: widget.notificationKey.toString(),
        notificationCategories: [],
      );
    } else {
      CustomNotificationsModel model = CustomNotificationsModel.fromRawJson(data);
      return model.notificationsList.singleWhere((element) =>
      element.notificationType == widget.notificationKey.toString(),
          orElse: () {
            return SingleCustomNotificationModel(startAt: '09:00',
                endAt: '15:00',
                notificationData: [],
                frequency: 0,
                notificationCategories: [],
                notificationType: widget.notificationKey.toString());
          }
      );
    }
  }

  void _selectEndTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (newTime != null) {
      updateNotificationSettings(endAt: '${newTime.hour}:${newTime.minute}');
      setState(() {
        _endTime = newTime;
      });
    }
  }

  void _onFrequencyChanged(double value) {
    updateNotificationSettings(frequency: value.toInt());
    setState(() {
      _frequency = value;
    });
  }


  @override
  void initState() {
    super.initState();
    _notificationsModel = getNotificationData();
    if (_notificationsModel != null) {
      _startTime = TimeOfDay.fromDateTime(
          DateTime.parse('2022-01-01 ${formatToDoubleDigit(_notificationsModel!.startAt!)}:00'));
      _endTime = TimeOfDay.fromDateTime(
          DateTime.parse('2022-01-01 ${formatToDoubleDigit(_notificationsModel!.endAt!)}:00'));
      _frequency = _notificationsModel?.frequency!.toDouble() ?? 0.0;
    }
  }

  void updateNotificationSettings({
    String? startAt,
    String? endAt,
    int? frequency,
    List<bool>? daysList,
    List<NotificationCategory>? categoriesList,
  }) {
    if (startAt != null) {
      _notificationsModel!.startAt = startAt;
    }

    if (frequency != null) {
      _notificationsModel!.frequency = frequency;
    }

    if (endAt != null) {
      _notificationsModel!.endAt = endAt;
    }

    if (daysList != null) {
      _notificationsModel!.notificationDays = daysList;
    }

    if(categoriesList != null) {
      _notificationsModel!.notificationCategories = categoriesList;
    }


    _updateNotificationInPreferences(_notificationsModel!);
  }

  _updateNotificationInPreferences(SingleCustomNotificationModel notificationModel) {
    final notificationsList = CustomNotificationsModel.fromRawJson(
        Preferences.instance.customNotifications);

    notificationsList.notificationsList.removeWhere((element) =>
    element.notificationType == widget.notificationKey.toString());

    notificationsList.notificationsList.add(notificationModel);

    Preferences.instance.customNotifications = notificationsList.toRawJson();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10.0),
          width: context.width,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .cardColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: kPrimaryColor.withOpacity(0.5), // Customize the shade color here
              width: 0.5, // Customize the border width as needed
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _selectStartTime(context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: kPrimaryColor,),
                          SizedBox(width: 5.0,),
                          Row(
                            children: [
                              Text('Starts at:', style: TextStyle(fontWeight: FontWeight.w600),),
                              SizedBox(width: 5.0,),
                              Text(_startTime.format(context))
                            ],
                          )

                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _selectEndTime(context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: kPrimaryColor,),
                          SizedBox(width: 5.0,),
                          Row(
                            children: [
                              Text('Ends at', style: TextStyle(fontWeight: FontWeight.w600),),
                              SizedBox(width: 5.0,),
                              Text(_endTime.format(context))
                            ],
                          )

                        ],
                      ),
                    )
                  ],),
              ),
              const SizedBox(height: 10.0),
              DaysOfWeekWidget(
                currentDaysList: _notificationsModel!.notificationDays ?? [],
                onDaysChanged: (newDaysList) {
                  updateNotificationSettings(daysList: newDaysList);
                },

              ),
              const SizedBox(height: 10.0),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Icon(Icons.speed, color: kPrimaryColor,)),
                  const SizedBox(width: 20.0,),
                  Row(
                    children: [
                      Text('${_frequency.toInt()}'),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 1.7,
                        child: Slider(
                          value: _frequency,
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          onChanged: _onFrequencyChanged,
                        ),
                      ),
                      Text('10'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Text('Notifications:', style: TextStyle(fontWeight: FontWeight.w600),),
                  SizedBox(width: 20.0,),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => NotificationsCategoriesScreen(selectedCategoryList: _notificationsModel?.notificationCategories ?? [],))).then((value) {
                              List<Categories> categoriesList = value;
                              if(categoriesList != null && categoriesList.isNotEmpty) {
                                List<Categories> selectedCategoriesList = categoriesList.where((element) => element.isSelected == true).toList();
                                List<NotificationCategory> notificationCategoryList = [];
                                for(final item in selectedCategoriesList) {
                                  notificationCategoryList.add(NotificationCategory(name: item.categoryName, id: item.categoryId));
                                  if(item == selectedCategoriesList.last) {
                                    updateNotificationSettings(
                                        categoriesList: notificationCategoryList);
                                  }
                                }

                              }
                          setState(() {
                            debugPrint('----> $value');
                          });
                        }
    );
                        
                      },
                      child: Text(getCategoriesName()))
                ],
              )
            ],
          ),
        )
      ],
    );
  }


  String getCategoriesName() {
    String name = 'Select Categories';
    if (_notificationsModel!.notificationCategories != null &&
        _notificationsModel!.notificationCategories!.isNotEmpty) {
      if (_notificationsModel!.notificationCategories!.length >= 2) {
        return '${_notificationsModel!.notificationCategories!.first.name}, ${_notificationsModel!
            .notificationCategories![1].name} ...';
      } else {
        return '${_notificationsModel!.notificationCategories!.first.name}';
      }
    }
    else {
      name = 'Select Categories';
    }
    return name;
  }

}
