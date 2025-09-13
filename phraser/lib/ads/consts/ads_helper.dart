import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:phraser/ads/consts/ads_constants.dart';
import 'package:phraser/ads/model/banner_ad_object.dart';
import 'package:phraser/util/preferences.dart';
class AdsHelper {
  /// A rewarded video ad that will be displayed when user wants to reset their tries.
  static RewardedAd? freeTriesRewardedAd;
  /// This banner ad will be displayed on the bottom of [showTriesCompletedDialog()] dialog
  static BannerAdObject themesBannerAd = BannerAdObject();

  static InterstitialAd? freeTriesInterstitialAd;


  static loadAdmobBannerAd() async {
    /// Load ads only when the premium feature is on from the database
    if (!Preferences.instance.isPremiumApp) {
      themesBannerAd.bannerAd = BannerAd(
        adUnitId: AdsConstants.bannerAdId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
            onAdLoaded: (loadedAd) {
              debugPrint('Banner ad loaded Successfully');
              themesBannerAd.isAdLoaded = true;
            },
            onAdFailedToLoad: (ad, error) {
              debugPrint('Ad failed $error');
              ad.dispose();
            }
        ),
      );
    themesBannerAd.bannerAd!.load();
  }
  }



  static loadAdmobInterstitialAd() async {
    /// Load ads only when the premium feature is on from the database
    if (!Preferences.instance.isPremiumApp) {
      await InterstitialAd.load(
          adUnitId: AdsConstants.interstitialAdId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
            debugPrint('InterstitialAd loaded');
            freeTriesInterstitialAd = ad;
          }, onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          }));
  }
  }


  static loadRewardedVideoAd() async {
    /// Load ads only when the premium feature is on from the database
    if (!Preferences.instance.isPremiumApp) {
      RewardedAd.load(
          adUnitId: AdsConstants.freeTriesVideoAdId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              freeTriesRewardedAd = ad;
              debugPrint('----> Rewarded ad loaded');
            },
            onAdFailedToLoad: (LoadAdError adError) {
              debugPrint('manual coins rewarded ad failed to load: ${adError.message}');
            },
          ));


  }
  }

}