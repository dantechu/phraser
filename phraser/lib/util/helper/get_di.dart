

import 'package:get/get.dart';
import 'package:phraser/payments/view_model/in_app_purchase_view_model.dart';
import 'package:phraser/screens/ai_quotes/view_model/chat_view_model.dart';
import 'package:phraser/services/view_model/categories_list_view_model.dart';
import 'package:phraser/services/view_model/phraser_view_model.dart';

Future<void> init() async {

  Get.lazyPut<CategoriesListViewModel>(() => CategoriesListViewModel());
  Get.lazyPut<InAppPurchaseViewModel>(() => InAppPurchaseViewModel());
  Get.lazyPut<PhraserViewModel>(() => PhraserViewModel());
  Get.put<ChatViewModel>(ChatViewModel());

}