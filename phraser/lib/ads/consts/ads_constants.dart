import 'dart:io';
import 'package:flutter/foundation.dart';

class AdsConstants {

  static String get bannerAdId {
    if (Platform.isAndroid) {
      return kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : 'ca-app-pub-9740790965972178/5199356403';
    } else if (Platform.isIOS) {
      return kDebugMode ? 'ca-app-pub-3940256099942544/2934735716' : 'ca-app-pub-9740790965972178/2454058974';
    } else {
      return '';
    }
  }


  static String get interstitialAdId {
    if (Platform.isAndroid) {
      return kDebugMode ? 'ca-app-pub-3940256099942544/1033173712' : 'ca-app-pub-9740790965972178/1439240649';
    } else if (Platform.isIOS) {
      return kDebugMode ? 'ca-app-pub-3940256099942544/4411468910' : 'ca-app-pub-9740790965972178/1827087604';
    } else {
      return '';
    }
  }


  static String get freeTriesVideoAdId {
    if (Platform.isAndroid) {
      return kDebugMode ? 'ca-app-pub-3940256099942544/5224354917' : 'ca-app-pub-9740790965972178/5271794003';
    } else if (Platform.isIOS) {
      return kDebugMode ? 'ca-app-pub-3940256099942544/1712485313' : 'ca-app-pub-9740790965972178/7088234716';
    } else {
      return '';
    }
  }


}
