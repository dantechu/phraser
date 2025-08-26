
import 'package:floor/floor.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/constant_strings.dart';

@dao
abstract class FavoritesDAO {
  @Query('SELECT * FROM ${ConstantStrings.kFavoritesTableName}')
  Future<List<Phraser>> getAllFavoritesPhrasers();


  @Query('SELECT * FROM ${ConstantStrings.kFavoritesTableName} WHERE id = :id')
  Stream<Phraser?> getFavoriteById(int id);

  @insert
  Future<void> addPhraserToFavorite(Phraser phraser);


  @delete
  Future<void> removeFromFavorites(Phraser phraser);


}