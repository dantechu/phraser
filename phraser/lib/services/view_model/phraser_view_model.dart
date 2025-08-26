
import 'package:get/get.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/Floor_db.dart';

class PhraserViewModel extends GetxController {

  int themePosition = 0;
  bool? _isFavorite;


  void changeThemePosition(int newPosition) {
    themePosition = newPosition;
    update();
  }

  set isFavorite(bool value) {
    _isFavorite = value;
    update();
  }

  bool get isFavorite => _isFavorite ?? false;



  void isFavorites(Phraser phraser) async {
    try {
      isFavorite = false;
      final database = FloorDB.instance.floorDatabase;
      FavoritesDAO dao = database.favoritesDAO;
      final data = dao.getFavoriteById(int.parse(phraser.phraserId));
      data.listen((event) {
        event == null ? isFavorite = false : isFavorite = true;
      });
    } catch (e) {
      isFavorite = false;
    }


  }


}