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
  const SpecificTimeNotificationWidget(
      {Key? key, required this.notificationKey})
      : super(key: key);

  final String notificationKey;

  @override
  State<SpecificTimeNotificationWidget> createState() =>
      _SpecificTimeNotificationWidgetState();
}

class _SpecificTimeNotificationWidgetState
    extends State<SpecificTimeNotificationWidget> {
  TimeOfDay _startTime = TimeOfDay(
    hour: 5,
    minute: 0,
  );
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
      CustomNotificationsModel model =
          CustomNotificationsModel.fromRawJson(data);
      return model.notificationsList.singleWhere(
          (element) =>
              element.notificationType == widget.notificationKey.toString(),
          orElse: () {
        return SingleCustomNotificationModel(
            startAt: '09:00',
            endAt: '15:00',
            notificationData: [],
            frequency: 0,
            notificationCategories: [],
            notificationType: widget.notificationKey.toString());
      });
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
      _startTime = TimeOfDay.fromDateTime(DateTime.parse(
          '2022-01-01 ${formatToDoubleDigit(_notificationsModel!.startAt!)}:00'));
      _endTime = TimeOfDay.fromDateTime(DateTime.parse(
          '2022-01-01 ${formatToDoubleDigit(_notificationsModel!.endAt!)}:00'));
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

    if (categoriesList != null) {
      _notificationsModel!.notificationCategories = categoriesList;
    }

    _updateNotificationInPreferences(_notificationsModel!);
  }

  _updateNotificationInPreferences(
      SingleCustomNotificationModel notificationModel) async {
    try {
      // Save to the new notification service
      await NotificationConfigService.instance
          .saveTimePeriodNotification(notificationModel);

      // Also update the legacy preferences system for compatibility
      try {
        CustomNotificationsModel? notificationsList;
        try {
          notificationsList = CustomNotificationsModel.fromRawJson(
              Preferences.instance.customNotifications);
        } catch (e) {
          // Create new model if parsing fails
          notificationsList = CustomNotificationsModel(notificationsList: []);
        }

        // Remove existing notification for this time period
        notificationsList.notificationsList.removeWhere((element) =>
            element.notificationType == widget.notificationKey.toString());

        // Add the updated notification
        notificationsList.notificationsList.add(notificationModel);

        // Save to legacy preferences
        Preferences.instance.customNotifications =
            notificationsList.toRawJson();
      } catch (e) {
        debugPrint('Error updating legacy preferences: $e');
        // Create new preferences entry
        final newNotificationsList =
            CustomNotificationsModel(notificationsList: [notificationModel]);
        Preferences.instance.customNotifications =
            newNotificationsList.toRawJson();
      }

      debugPrint(
          'Updated ${widget.notificationKey} notification settings successfully');
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Selection Section
            Row(
              children: [
                Expanded(
                  child: _buildTimeCard(
                    context,
                    title: 'Start Time',
                    time: _startTime.format(context),
                    emoji: '⏰',
                    onTap: () => _selectStartTime(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard(
                    context,
                    title: 'End Time',
                    time: _endTime.format(context),
                    emoji: '⏰',
                    onTap: () => _selectEndTime(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Days of Week Section
            Text(
              'Active Days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            DaysOfWeekWidget(
              currentDaysList: _notificationsModel!.notificationDays ?? [],
              onDaysChanged: (newDaysList) {
                updateNotificationSettings(daysList: newDaysList);
              },
            ),
            const SizedBox(height: 20),
            // Frequency Section
            Text(
              'Frequency',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(
                    '🔔',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Frequency',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_frequency.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Theme.of(context).primaryColor,
                            inactiveTrackColor:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            thumbColor: Theme.of(context).primaryColor,
                            overlayColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: _frequency,
                            min: 0.0,
                            max: 10.0,
                            divisions: 10,
                            onChanged: _onFrequencyChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Categories Section
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoriesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context, {
    required String title,
    required String time,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsCategoriesScreen(
              selectedCategoryList:
                  _notificationsModel?.notificationCategories ?? [],
            ),
          ),
        ).then((value) {
          List<Categories> categoriesList = value;
          if (categoriesList != null && categoriesList.isNotEmpty) {
            List<Categories> selectedCategoriesList = categoriesList
                .where((element) => element.isSelected == true)
                .toList();
            List<NotificationCategory> notificationCategoryList = [];
            for (final item in selectedCategoriesList) {
              notificationCategoryList.add(
                NotificationCategory(
                  name: item.categoryName,
                  id: item.categoryId,
                ),
              );
              if (item == selectedCategoriesList.last) {
                updateNotificationSettings(
                  categoriesList: notificationCategoryList,
                );
              }
            }
          }
          setState(() {
            debugPrint('----> $value');
          });
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Text(
              '🎯',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    getCategoriesName(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getCategoriesName() {
    try {
      if (_notificationsModel?.notificationCategories != null &&
          _notificationsModel!.notificationCategories!.isNotEmpty) {
        final categories = _notificationsModel!.notificationCategories!;
        if (categories.length >= 2) {
          return '${categories.first.name}, ${categories[1].name} & ${categories.length - 2} more';
        } else {
          return categories.first.name ?? 'Category';
        }
      }
    } catch (e) {
      debugPrint('Error getting category names: $e');
    }
    return 'Select Categories';
  }
}
