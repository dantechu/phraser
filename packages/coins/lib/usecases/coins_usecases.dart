import 'package:coins/services/coins_local_service.dart';

class CoinsUseCases {
  CoinsUseCases();

  Future<int> getAvailableCoins() async {
   return await CoinsLocalService().getAvailableCoins();
  }

  Future<void> consumeCoins(int numberOfCoinsToBeConsumed) async {
    await CoinsLocalService().consumeCoins(numberOfCoinsToBeConsumed);
  }

  Future<void> addCoins(int numberOfCoinsToBeAdded) async {
     await CoinsLocalService().addCoins(numberOfCoinsToBeAdded);
  }

}