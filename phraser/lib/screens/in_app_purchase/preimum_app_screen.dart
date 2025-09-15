import 'dart:io';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/payments/view_model/in_app_purchase_view_model.dart';
import 'package:phraser/util/colors.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/util/terms_and_policy_text_widget.dart';

class PremiumAppScreen extends StatefulWidget {
  const PremiumAppScreen({Key? key}) : super(key: key);

  @override
  State<PremiumAppScreen> createState() => _PremiumAppScreenState();
}

class _PremiumAppScreenState extends State<PremiumAppScreen> {


  final purchaseViewModel = Get.find<InAppPurchaseViewModel>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    purchaseViewModel.init();
    initializeStreamSubscription();
  }


  Future<void> initializeStreamSubscription() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        purchaseViewModel.inAppPurchaseInstance.purchaseStream;
    purchaseViewModel.subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList, purchaseViewModel);
    }, onDone: () {
      purchaseViewModel.subscription.cancel();
    }, onError: (error) {
      purchaseViewModel.subscription.resume();
    });
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList, InAppPurchaseViewModel purchaseViewModel) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        purchaseViewModel.purchasePending = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {

          Fluttertoast.showToast(msg: 'Error in payment');
          purchaseViewModel.purchasePending = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool validPurchase = purchaseViewModel.verifyPurchase(purchaseDetails);
          if (validPurchase) {
            _processVerifiedPurchase(purchaseDetails, purchaseViewModel);
          } else {
            Fluttertoast.showToast(msg: 'Error in payment');
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await purchaseViewModel.inAppPurchaseInstance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _restorePurchases(InAppPurchaseViewModel purchaseViewModel) async {
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition = purchaseViewModel
          .inAppPurchaseInstance
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final QueryPurchaseDetailsResponse pastPurchases = await androidAddition.queryPastPurchases();
      if (pastPurchases.pastPurchases.isEmpty) {
        Fluttertoast.showToast(msg: 'No previous purchase found');
      } else {
        purchaseViewModel.inAppPurchaseInstance.restorePurchases();
      }
    } else {
      ///[31-3-23] Till this date there was no function to query past purchases on iOS
      ///So we need to directly call restorePurchases for iOS platform.
      purchaseViewModel.inAppPurchaseInstance.restorePurchases();
    }
  }

  void _processVerifiedPurchase(
      PurchaseDetails purchaseDetails, InAppPurchaseViewModel purchaseViewModel) async {


    /// updated subscription details in current app session
    Preferences.instance.isPremiumApp = true;
    purchaseViewModel.purchasePending = false;

    if (purchaseDetails.status == PurchaseStatus.restored) {
      /// Subscription restored successfully
      Fluttertoast.showToast(msg: 'Purchase restored successfully');
    } else {
      /// Subscription purchased successfully
      Fluttertoast.showToast(msg: 'Purchase successful :)');
    }

  }



  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 0.0, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close, size: 27.0,)),
                        SizedBox(width: 15.0),
                        //  Text('Settings', style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold ),)
                      ],
                    ),

                  ),
                ),
                SizedBox(height: 0.0),
                Container(height: 100.0, width: 100.0, child: Image.asset(AppAssets.kCrownImage)),
                SizedBox(height: 10.0),
                Text(
                  'Get Premium',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: kPrimaryColor),
                ),
                SizedBox(height: 40.0),
                _getPremiumItemWidget('Full access to all the features'),
                SizedBox(
                  height: 15.0,
                ),
                _getPremiumItemWidget('Cancel anytime when you want'),
                SizedBox(
                  height: 15.0,
                ),
                _getPremiumItemWidget('Ad-free experience'),
                SizedBox(
                  height: 15.0,
                ),
                _getPremiumItemWidget('Unlock all categories'),
                SizedBox(
                  height: 15.0,
                ),
                _getPremiumItemWidget('only \$1.99/Month, billed monthly'),
                SizedBox(
                  height: 15.0,
                ),
                _getPremiumItemWidget('Unlimited access to AI quotes assistant'),
                SizedBox(
                  height: 90.0,
                ),
              ],
            ),
            Column(
              children: [
                const TermsAndPolicyTextWidget(),
                const SizedBox(height: 20.0,),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45.0,
                    margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: ElevatedButton(
                        onPressed: () {
                          try {
                            final productItem = purchaseViewModel.products.first;
                            purchaseViewModel.purchaseItem(productItem);
                          } catch (e) {
                            Fluttertoast.showToast(msg: 'Please try again later');
                          }
                        },
                        child: const Text(
                          'Continue (\$1.99 / Month)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        ))),
               const  SizedBox(height: 20.0,),
                 GestureDetector(
                     onTap: (){
                       _restorePurchases(purchaseViewModel);
                     },
                     child: Text("Already Subscribed ?", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),)),
                const SizedBox(height: 30.0,),
              ],
            )
        ],
      ),
          )),
    );
  }

  Widget _getPremiumItemWidget(String text) {
    return Row(
      children: [
        SizedBox(
          width: 15.0,
        ),
        Container(height: 22.0, width: 22.0, child: Image.asset(AppAssets.kCheck)),
        SizedBox(
          width: 10.0,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}