import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phraser/payments/delegate/payment_wraper_delegate.dart';

class InAppPurchaseViewModel extends GetxController {
  final InAppPurchase inAppPurchaseInstance = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];

  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? queryProductError;
  final String _basicMonthlySubscription = 'basic_monthly_subscription';

  final List<String> _kProductIds = <String>[];
  StreamSubscription<List<PurchaseDetails>> get subscription => _subscription;
  set subscription(StreamSubscription<List<PurchaseDetails>> subscription) {
    _subscription  = subscription;
    update();
  }

  set purchasePending(bool value) {
    _purchasePending = value;
    update();
  }

  set loading(bool value) {
    _loading = value;
    update();
  }

  set isAvailable(bool value) {
    _isAvailable = value;
    update();
  }
  bool get loading => _loading;
  bool get isAvailable => _isAvailable;

  bool get purchasePending => _purchasePending;


  Future<void> init() async {
    _kProductIds.add(_basicMonthlySubscription);
    await _initStoreInfo();
    update();
  }

  Future<void> _initStoreInfo() async {
    final bool available = await inAppPurchaseInstance.isAvailable();
    if (!available) {
      isAvailable = available;
      products = [];
      purchases = [];
      purchasePending = false;
      loading = false;
      update();
      return;
    }

    if (Platform.isIOS) {
      var iosPlatformAddition = inAppPurchaseInstance.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(IOSPaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse = await inAppPurchaseInstance.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      queryProductError = productDetailResponse.error!.message;
      isAvailable = available;
      products = productDetailResponse.productDetails;
      purchases = [];
      _notFoundIds = productDetailResponse.notFoundIDs;
      purchasePending = false;
      loading = false;
      update();
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      queryProductError = null;
      isAvailable = available;
      products = productDetailResponse.productDetails;
      purchases = [];
      _notFoundIds = productDetailResponse.notFoundIDs;
      purchasePending = false;
      loading = false;
      update();
      return;
    }
    isAvailable = available;
    products = productDetailResponse.productDetails;
    _notFoundIds = productDetailResponse.notFoundIDs;
    purchasePending = false;
    loading = false;
    update();
  }

  void finishPendingTransactions() async {
    var paymentWrapper = SKPaymentQueueWrapper();
    var transactions = await paymentWrapper.transactions();
    transactions.forEach((transaction) async {
      await paymentWrapper.finishTransaction(transaction);
    });
    update();
  }

  void disposeService() {
    if (Platform.isIOS) {
      var iosPlatformAddition = inAppPurchaseInstance.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    update();
  }



  bool verifyPurchase(PurchaseDetails purchaseDetails) {
    return purchaseDetails.productID.toString() == _basicMonthlySubscription;
  }


  Future<void> confirmPriceChange() async {
    if (Platform.isIOS) {
      var iapStoreKitPlatformAddition = inAppPurchaseInstance.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }


  GooglePlayPurchaseDetails?  getOldSubscription(
      GooglePlayProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == _basicMonthlySubscription && purchases[_basicMonthlySubscription] != null) {
      oldSubscription = purchases[_basicMonthlySubscription]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }


  void purchaseItem(ProductDetails productDetails) {

    Map<String, PurchaseDetails> _purchases = Map.fromEntries(purchases.map((PurchaseDetails purchase) {
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));

    if(Platform.isIOS) {
      late PurchaseParam purchaseParam;
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
      try {
        inAppPurchaseInstance.buyNonConsumable(purchaseParam: purchaseParam);
      } catch(e) {
        debugPrint('--> error in iOS purchase: $e');
      }
    } else {
      final GooglePlayPurchaseDetails? oldSubscription =
      getOldSubscription(productDetails as GooglePlayProductDetails, _purchases);

      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: productDetails,
          changeSubscriptionParam: oldSubscription != null
              ? ChangeSubscriptionParam(
              oldPurchaseDetails: oldSubscription,)
              : null);
      inAppPurchaseInstance.buyNonConsumable(purchaseParam: purchaseParam);
    }

  }



}