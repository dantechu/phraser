import 'dart:convert';

enum CustomNotificationType {morning, afternoon, evening,midnight}

class CustomNotificationsModel {

  CustomNotificationsModel({required this.notificationsList});
  late final List<SingleCustomNotificationModel> notificationsList;


  CustomNotificationsModel.fromJson(Map<String, dynamic> json){

    if (json['notifications_list'] != null) {
      notificationsList = [];
      json['notifications_list'].forEach((v) {
        notificationsList.add(SingleCustomNotificationModel.fromJson(v));
      });
    } else {
      notificationsList = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notifications_list'] = notificationsList
        .map((v) => v.toJson())
        .toList();
    return data;
  }


  String toRawJson() => json.encode(toJson());

  factory CustomNotificationsModel.fromRawJson(String str) =>
      CustomNotificationsModel.fromJson(json.decode(str));
}

class SingleCustomNotificationModel {
  SingleCustomNotificationModel({
    required this.startAt,
    required this.endAt,
    required this.frequency,
    required this.notificationData,
    required this.notificationType,
    this.notificationDays,
     this.notificationCategories
  });
    String? startAt;
    String? endAt;
    String? notificationType;
    int? frequency;
    List<String>? notificationData;
    List<bool>? notificationDays;
    List<NotificationCategory>? notificationCategories = [];

  SingleCustomNotificationModel.fromJson(Map<String, dynamic> json){
    startAt = json['start_at'];
    notificationType = json['notification_type'];
    endAt = json['end_at'];
    frequency = json['frequency'];
    if(json['notification_data'] != null) {
      notificationData = List.castFrom<dynamic, String>(json['notification_data']);
    } else {
      notificationData = [];
    }
    if(json['notification_days'] != null) {
      notificationDays = List.castFrom<dynamic, bool>(json['notification_days']);
    } else {
      notificationDays = [];
    }

    if (json['notifications_categories'] != null) {
      notificationCategories = [];
      json['notifications_categories'].forEach((v) {
        notificationCategories!.add(NotificationCategory.fromJson(v));
      });
    } else {
      notificationCategories = [];
    }

  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['start_at'] = startAt;
    _data['end_at'] = endAt;
    _data['notification_type'] = notificationType;
    _data['frequency'] = frequency;
    _data['notification_data'] = notificationData;
    _data['notification_days'] = notificationDays;
    _data['notifications_categories'] = notificationCategories!
        .map((v) => v.toJson())
        .toList();
    return _data;
  }




  String toRawJson() => json.encode(toJson());

  factory SingleCustomNotificationModel.fromRawJson(String str) =>
      SingleCustomNotificationModel.fromJson(json.decode(str));

}


class NotificationCategory {
  NotificationCategory({
    required this.name,
    required this.id
});

  late final String name;
  late final String id;




  NotificationCategory.fromJson(Map<String, dynamic> json){
    name = json['name'];
    id = json['id'];
  }


  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['id'] = id;

    return _data;
  }

}