import 'package:google_mobile_ads/google_mobile_ads.dart';

/// This will hold two values. 1 Actual banner-ad. 2 A bool value that will determine either the
/// ad is loaded or not.
class BannerAdObject {
  BannerAd? bannerAd;
  bool? isAdLoaded;
}