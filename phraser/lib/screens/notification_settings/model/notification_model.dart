import 'dart:convert';

class NotificationsModel {
  NotificationsModel({
    required this.startAt,
    required this.endAt,
    required this.frequency,
    required this.notificationData,
  });
  late final String startAt;
  late final String endAt;
  late final int frequency;
  late final List<String> notificationData;

  NotificationsModel.fromJson(Map<String, dynamic> json){
    startAt = json['start_at'];
    endAt = json['end_at'];
    frequency = json['frequency'];
    notificationData = List.castFrom<dynamic, String>(json['notification_data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['start_at'] = startAt;
    _data['end_at'] = endAt;
    _data['frequency'] = frequency;
    _data['notification_data'] = notificationData;
    return _data;
  }


  String toRawJson() => json.encode(toJson());

  factory NotificationsModel.fromRawJson(String str) =>
      NotificationsModel.fromJson(json.decode(str));

}