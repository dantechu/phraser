import 'package:core/core.dart';
import 'package:core/utils/internet_connection_checker.dart';

class ConnectivityController extends GetxController {
  bool _isConnectivityIsolateRunning = true;
  set isConnectivityIsolateRunning(bool val) {
    _isConnectivityIsolateRunning = val;
    update();
  }

  bool get isConnectivityIsolateRunning => _isConnectivityIsolateRunning;

  set isUserOutFromApp(bool val) {
    userInApp = val;
  }

  bool get isUserOutFromApp => userInApp;

  Future checkConnectionIsolate({required Function() callBackWhenInternetConnectionLost}) async {
    await InternetConnectionChecker.instance
        .checkConnection(callBackWhenInternetConnectionLost: callBackWhenInternetConnectionLost);
  }

  Future<bool> isInternetAvailable() async {
    return await InternetConnectionChecker.instance.isInternetAvailable();
  }
}
