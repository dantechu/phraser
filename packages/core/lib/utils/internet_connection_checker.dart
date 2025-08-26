import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:core/core.dart';

///[checkInternet] is used to fetch data from second isolate and send to main isolate.
bool checkInternet = true;

///[userInApp] is used to check user availability in app.
bool userInApp = true;

///[internetCheckingIsolate] is a second isolate to check internet without holding main isolate
Future internetCheckingIsolate() async {
  final controller = Get.find<ConnectivityController>();
  final ReceivePort otherReceivePort = ReceivePort();
  final isolate = await Isolate.spawn<SendPort>(connectivityTask, otherReceivePort.sendPort, debugName: 'connection_isolate');
  otherReceivePort.listen((message) {
    if (message is bool) {
      checkInternet = message;
      if (!checkInternet) {
        isolate.kill(priority: Isolate.immediate);
        controller.isConnectivityIsolateRunning = false;
      } else {
        controller.isConnectivityIsolateRunning = true;
      }
    }
  });
}

///[connectivityTask] this function has a heavy task that fetch google and check the internet exist or not if yes then return true else return false
Future connectivityTask(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        sendPort.send(true);
      } else {
        sendPort.send(false);
      }
    } catch (e) {
      sendPort.send(false);
    }
  });
}

class InternetConnectionChecker {
  InternetConnectionChecker._();
  static final InternetConnectionChecker _instance = InternetConnectionChecker._();
  static InternetConnectionChecker get instance => _instance;

  Future checkConnection({required Function() callBackWhenInternetConnectionLost}) async {
    await internetCheckingIsolate();
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        if (!checkInternet) {
          checkInternet = true;
          if (userInApp) {
            callBackWhenInternetConnectionLost.call();
          }
        }
      } on SocketException catch (_) {
        checkInternet = true;
        callBackWhenInternetConnectionLost.call();
      }
    });
  }

  Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
