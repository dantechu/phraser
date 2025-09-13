library core;

import 'controllers/connectivity_controller.dart';
import 'core.dart';

//Local Packages
export 'utils/asset_provider.dart';
export 'utils/size_ext.dart';
export 'controllers/connectivity_controller.dart';

//Pub Packages
export 'package:get/get.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:firebase_remote_config/firebase_remote_config.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:flutter_secure_storage/flutter_secure_storage.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:result_type/result_type.dart';

class CorePackage {
  CorePackage.registerDependencies() {
    Get.put(ConnectivityController(), permanent: true);
  }
}
