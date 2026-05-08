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
import 'package:phraser/util/status_bar_helper.dart';
import 'package:phraser/util/helper/route_helper.dart';

class PremiumAppScreen extends StatefulWidget {
  final bool showCloseButton;

  const PremiumAppScreen({Key? key, this.showCloseButton = false}) : super(key: key);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return StatusBarHelper.standardSafeArea(
      context: context,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Close button and header
                        Row(
                          children: [
                            if (!widget.showCloseButton)
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 20,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            if (widget.showCloseButton) const Spacer(),
                            if (widget.showCloseButton)
                              InkWell(
                                onTap: () => Get.offAllNamed(RouteHelper.phraserScreen),
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        // Crown icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            AppAssets.kCrownImage,
                            height: 40,
                            width: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Title and subtitle
                         Text(
                          'Unlock Premium',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                         Text(
                          'Get unlimited access to all features',
                          style: TextStyle(
                            fontSize: 14,
                            color: kPrimaryColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Features Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Features Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Features',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildFeatureItem(
                              context,
                              Icons.auto_awesome,
                              'Full access to all features',
                              'Unlock every tool and capability',
                              Colors.purple,
                            ),
                            _buildFeatureItem(
                              context,
                              Icons.block,
                              'Ad-free experience',
                              'Enjoy uninterrupted usage',
                              Colors.green,
                            ),
                            _buildFeatureItem(
                              context,
                              Icons.category,
                              'Unlock all categories',
                              'Access premium content libraries',
                              Colors.blue,
                            ),
                            _buildFeatureItem(
                              context,
                              Icons.psychology,
                              'AI quotes assistant',
                              'Unlimited personalized quotes',
                              Colors.orange,
                            ),
                            _buildFeatureItem(
                              context,
                              Icons.workspace_premium,
                              'Lifetime access',
                              'One-time payment, yours forever',
                              Colors.amber,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pricing Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor.withOpacity(0.1),
                            kPrimaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.star,
                              color: kPrimaryColor,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '\$4.99',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                            Text(
                              'lifetime access',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'One-time payment • No subscription',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Subscribe Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor,
                            kPrimaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            final productItem = purchaseViewModel.products.first;
                            purchaseViewModel.purchaseItem(productItem);
                          } catch (e,s) {
                            Fluttertoast.showToast(msg: 'Something went wrong.Please try again later');
                            print('Error in purchasing item: $e');
                            print('Stack trace: $s');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Get Lifetime Premium - \$4.99',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Restore Purchase Button
                    TextButton(
                      onPressed: () => _restorePurchases(purchaseViewModel),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Already purchased? Restore purchases',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms and Policy
                    const TermsAndPolicyTextWidget(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor, {
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Check icon
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 56),
            height: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[200],
          ),
      ],
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