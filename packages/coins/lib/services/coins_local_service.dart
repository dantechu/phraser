import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class CoinsLocalService {
  Box? _box;
  final String _coinsDB = 'coinsDB';
  final String _coins = 'coins';

  Future<int> getAvailableCoins() async {
    _box = await Hive.openBox(_coinsDB);
    return _box!.get(_coins, defaultValue: 0);
  }


  Future<void> consumeCoins(int numberOfCoinsToBeConsumed) async {
    _box = await Hive.openBox(_coinsDB);
    final totalAvailableCoins =  _box!.get(_coins, defaultValue: 0);
    if(totalAvailableCoins > 0) {
      final remainingCoins = totalAvailableCoins - numberOfCoinsToBeConsumed;
      _box!.put(_coins, remainingCoins);
    } else {
      debugPrint('Unable to consume $numberOfCoinsToBeConsumed from $totalAvailableCoins coins');
    }
  }


  Future<void> addCoins(int numberOfCoinsToBeAdded) async {
    _box = await Hive.openBox(_coinsDB);
    final availableCoins =  _box!.get(_coins, defaultValue: 0);
    final  totalCoins = availableCoins + numberOfCoinsToBeAdded;
    _box!.put(_coins, totalCoins);
  }

}