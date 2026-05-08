
import 'package:get/get.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';

class PhraserViewModel extends GetxController {

  var themePosition = 0.obs;
  bool? _isFavorite;
  String? _currentPhraserId; // Track current phraser to avoid unnecessary DB calls


  void changeThemePosition(int newPosition) {
    themePosition.value = newPosition;
    update();
  }

  set isFavorite(bool value) {
    _isFavorite = value;
    update();
  }

  bool get isFavorite => _isFavorite ?? false;



  Future<void> isFavorites(Phraser phraser) async {
    // Avoid unnecessary database calls if checking the same phraser
    if (_currentPhraserId == phraser.phraserId) return;

    try {
      _currentPhraserId = phraser.phraserId;
      isFavorite = false;

      final database = FloorDB.instance.floorDatabase;
      FavoritesDAO dao = database.favoritesDAO;

      // Use a one-time check instead of stream listener to avoid memory leaks
      final favoriteItem = await dao.getFavoriteById(phraser.phraserId).first;
      isFavorite = favoriteItem != null;

      // Trigger UI update
      update();
    } catch (e,s) {
      isFavorite = false;
      update();
    }
  }

  // Method to clear the cached phraser ID to force a refresh
  void clearCachedPhraserId() {
    _currentPhraserId = null;
  }


}