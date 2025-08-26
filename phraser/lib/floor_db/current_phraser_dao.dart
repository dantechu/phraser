import 'package:floor/floor.dart';
import '../services/model/phreasers_list_model.dart';
import '../util/constant_strings.dart';

@dao
abstract class CurrentPhrasersDAO {

  @Query('SELECT * FROM  ${ConstantStrings.kCurrentPhrasersTableName}')
  Future<List<Phraser>> getAllCurrentPhrasers();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllCurrentPhrasers(List<Phraser> phrasersList);

  @Query("DELETE FROM ${ConstantStrings.kCurrentPhrasersTableName}")
  Future<void> deleteCurrentPhrasers();
}