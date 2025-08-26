import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:phraser/screens/notification_settings/model/notification_model.dart';


class NotificationConfigService {
  NotificationConfigService._();

  static final NotificationConfigService _instance = NotificationConfigService._();

  static NotificationConfigService get instance => _instance;
  final notificationsConfigDB = 'notificationsConfig';
  final String _notificationDetails = 'subscription_details';
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



}
