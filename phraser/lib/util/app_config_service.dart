import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
class AppConfigService {
  AppConfigService._();

  static final AppConfigService _instance = AppConfigService._();

  static AppConfigService get instance => _instance;
  final _premiumConfigDB = 'premiumConfig';
  final String _adminPanelIdKey = 'admin_panel_id';
  late Box? _box;
  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    /// A key to read/write secure key from flutter secure storage.
    const String premiumConfigKey = 'premiumConfigKey';
    const secureStorage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    final encryptionKey = await secureStorage.read(key: premiumConfigKey);

    /// Create new secure key if not already exists.
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: premiumConfigKey,
        value: base64UrlEncode(key),
      );
    }

    /// Read secure key from flutter secure storage
    final key = await secureStorage.read(key: premiumConfigKey);
    final encryptionKeyRead = base64Url.decode(key!);

    /// Open Hive box using secure key
    _box = await Hive.openBox(_premiumConfigDB, encryptionCipher: HiveAesCipher(encryptionKeyRead));

    /// Once Hive DB is initialized, automatically fetch remote config from the server.
    await _fetchFromRC();
  }

  Future<void> _fetchFromRC() async {
    try {
      await _remoteConfig
          .setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(minutes: 1), minimumFetchInterval: Duration.zero));
      await _remoteConfig.fetchAndActivate();
      adminPanelID = _remoteConfig.getString(_adminPanelIdKey);
      debugPrint('admin panel key: $adminPanelID');
    } catch (e, s) {
      debugPrint('Trace $s: $e ');
    }
  }


  set adminPanelID(String? routeName) {
    _box!.put(_adminPanelIdKey, routeName);
  }



  String get adminPanelID => (_box!.get(_adminPanelIdKey) as String?) ?? '';
}
