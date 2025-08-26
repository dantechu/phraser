library coins;

import 'package:coins/usecases/coins_usecases.dart';
import 'package:core/core.dart';


class CoinsPackage {

  CoinsPackage.registerDependencies() {
    Get.lazyPut(() => CoinsUseCases(), fenix: true);
  }

}
