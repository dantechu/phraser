import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:phraser/screens/notification_settings/model/notification_model.dart';
import 'package:phraser/screens/notification_settings/model/custom_notifications_model.dart';


class NotificationConfigService {
  NotificationConfigService._();

  static final NotificationConfigService _instance = NotificationConfigService._();

  static NotificationConfigService get instance => _instance;
  final notificationsConfigDB = 'notificationsConfig';
  final String _notificationDetails = 'subscription_details';
  final String _customNotificationDetails = 'custom_notification_details';
  late Box? _box;

  Future<void> initialize() async {
    /// A key to read/write secure key from flutter secure storage.
    const String notificationConfigKey = 'notificationConfigKey';
    const secureStorage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    final encryptionKey = await secureStorage.read(key: notificationConfigKey);

    /// Create new secure key if not already exists.
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: notificationConfigKey,
        value: base64UrlEncode(key),
      );
    }

    /// Read secure key from flutter secure storage
    final key = await secureStorage.read(key: notificationConfigKey);
    final encryptionKeyRead = base64Url.decode(key!);

    /// Open Hive box using secure key
    _box = await Hive.openBox(notificationsConfigDB, encryptionCipher: HiveAesCipher(encryptionKeyRead));
  }

  set notificationDetails(NotificationsModel? detailsModel) {
    _box!.put(_notificationDetails, detailsModel!.toRawJson());
  }


  NotificationsModel? get notificationDetails {
    if(_box!.get(_notificationDetails) == null) {
      return null;
    } else {
      return NotificationsModel.fromRawJson(_box!.get(_notificationDetails) as String);
    }
  }

  /// Custom notification settings storage and retrieval
  set customNotificationDetails(CustomNotificationsModel? customModel) {
    if (customModel != null) {
      _box!.put(_customNotificationDetails, customModel.toRawJson());
    } else {
      _box!.delete(_customNotificationDetails);
    }
  }

  CustomNotificationsModel? get customNotificationDetails {
    if(_box!.get(_customNotificationDetails) == null) {
      return null;
    } else {
      return CustomNotificationsModel.fromRawJson(_box!.get(_customNotificationDetails) as String);
    }
  }

  /// Save specific time period notification settings
  Future<void> saveTimePeriodNotification(SingleCustomNotificationModel notification) async {
    var existingCustomNotifications = customNotificationDetails;
    
    if (existingCustomNotifications == null) {
      // Create new custom notifications model
      existingCustomNotifications = CustomNotificationsModel(
        notificationsList: [notification]
      );
    } else {
      // Update existing notification for this time period or add new one
      final existingIndex = existingCustomNotifications.notificationsList
          .indexWhere((n) => n.notificationType == notification.notificationType);
      
      if (existingIndex >= 0) {
        // Replace existing notification for this time period
        existingCustomNotifications.notificationsList[existingIndex] = notification;
      } else {
        // Add new time period notification
        existingCustomNotifications.notificationsList.add(notification);
      }
    }
    
    // Save updated custom notifications
    customNotificationDetails = existingCustomNotifications;
  }

  /// Remove specific time period notification settings
  Future<void> removeTimePeriodNotification(String timePeriod) async {
    var existingCustomNotifications = customNotificationDetails;
    
    if (existingCustomNotifications != null) {
      existingCustomNotifications.notificationsList
          .removeWhere((n) => n.notificationType == timePeriod);
      
      if (existingCustomNotifications.notificationsList.isEmpty) {
        customNotificationDetails = null; // Remove entirely if empty
      } else {
        customNotificationDetails = existingCustomNotifications;
      }
    }
  }

  /// Get notification settings for specific time period
  SingleCustomNotificationModel? getTimePeriodNotification(String timePeriod) {
    final customNotifications = customNotificationDetails;
    
    if (customNotifications != null) {
      try {
        return customNotifications.notificationsList
            .firstWhere((n) => n.notificationType == timePeriod);
      } catch (e) {
        return null; // Not found
      }
    }
    
    return null;
  }

}
