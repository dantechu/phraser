import 'package:coins/usecases/coins_usecases.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/floor_db/current_phraser_dao.dart';
import 'package:phraser/screens/notification_settings/notification_helper.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/util/Floor_db.dart';
import 'package:phraser/util/helper/route_helper.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/utils.dart';
import 'package:phraser/main.dart' as app_main;

import '../services/view_model/categories_list_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _categoriesListViewModel = Get.put(CategoriesListViewModel());


  @override
  void initState() {
    super.initState();
    validateApp();
  }


  validateApp() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        NotificationHelper.instance.checkPendingNotifications();
      Future.delayed(const Duration(seconds: 1), () async  {
        if(Preferences.instance.isFirstOpen) {
          final CoinsUseCases _coinsUseCase = Get.find<CoinsUseCases>();
          final availableCoins = await _coinsUseCase.getAvailableCoins();
          if(availableCoins <= 0) {
            _coinsUseCase.addCoins(10);
          }
          loadPhrasersData();
          Get.offAllNamed(RouteHelper.introductionScreen);
        }else {
          updateData();
          loadPhrasersData();


          ///  Loads ads here

          AdsHelper.loadRewardedVideoAd();
          AdsHelper.loadAdmobInterstitialAd();



          await getCurrentPhrasersList();
          testPrint('current phrasersList size is: ${DataRepository().currentPhrasersList.length}');
          await Future.delayed(Duration(seconds: 3));
          
          // Check if app was launched from a notification (cold start)
          await _handleColdStartNotification();
         }
      });

    });
  }

  void updateData() {
    try {
      _categoriesListViewModel.getCategories();
      _categoriesListViewModel.getSectionsList();
    } catch (e) {
      debugPrint('---> Internet not avaialable');
    }
  }


  void loadPhrasersData()  async {
    await _categoriesListViewModel.checkForData();
  }

  Future getCurrentPhrasersList() async {
    final database = FloorDB.instance.floorDatabase;
    CurrentPhrasersDAO phrasersDAO = database.currentPhraserDAO;
    try {
      DataRepository().currentPhrasersList = await phrasersDAO.getAllCurrentPhrasers();
    } catch (e) {
      debugPrint('---> unable to fetch current phrasers');
    }
  }

  /// Handle cold start notification navigation
  Future<void> _handleColdStartNotification() async {
    try {
      final launchDetails = app_main.getLaunchNotificationDetails();
      
      if (launchDetails?.didNotificationLaunchApp == true) {
        final payload = launchDetails?.notificationResponse?.payload;
        debugPrint('Cold start detected with payload: $payload');
        
        // Clear the launch notification so it doesn't trigger again
        app_main.clearLaunchNotificationDetails();
        
        // Handle the notification payload
        if (payload != null && payload.isNotEmpty) {
          // Let notification helper handle the navigation
          NotificationHelper.handleColdStartNotification(payload);
        } else {
          // No valid payload, navigate to main screen
          Get.offAllNamed(RouteHelper.phraserScreen);
        }
      } else {
        // Normal app launch, navigate to main screen
        Get.offAllNamed(RouteHelper.phraserScreen);
      }
    } catch (e) {
      debugPrint('Error handling cold start notification: $e');
      // Fallback: navigate to main screen
      Get.offAllNamed(RouteHelper.phraserScreen);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 120.0,
                width: 120.0,
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    child: Image.asset('assets/app_icon.png'))),
            Container(
              margin: EdgeInsets.only(top: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Powered with AI Assistant',
                    style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0,),
                  Text(
                    'Use AI to generate unlimited life changing quotes',
                    style: TextStyle(fontSize: 14.0,),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
