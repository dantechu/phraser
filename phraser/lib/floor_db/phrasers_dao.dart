
import 'package:floor/floor.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';

import '../util/constant_strings.dart';

@dao
abstract class PhrasersDAO {


  @Query('SELECT * FROM  ${ConstantStrings.kPhrasersTableName} WHERE categoryName = :name')
  Future<List<Phraser>> getAllPhrasers(String  name);

  @Query('SELECT * FROM  ${ConstantStrings.kPhrasersTableName}')
  Future<List<Phraser>> getAllQuotesFromAllCategories();

  @Query('SELECT * FROM  ${ConstantStrings.kPhrasersTableName} WHERE categoryId = :categoryId')
  Future<List<Phraser>> getPhrasersByCategoryId(String categoryId);

  @Query('SELECT COUNT(*) FROM  ${ConstantStrings.kPhrasersTableName} WHERE categoryId = :categoryId')
  Future<int?> getPhraserCountByCategoryId(String categoryId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllPhrasers(List<Phraser> phrasersList);


}