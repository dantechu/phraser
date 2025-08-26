
import 'package:floor/floor.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';

import '../util/constant_strings.dart';

@dao
abstract class PhrasersDAO {


  @Query('SELECT * FROM  ${ConstantStrings.kPhrasersTableName} WHERE categoryName = :name')
  Future<List<Phraser>> getAllPhrasers(String  name);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllPhrasers(List<Phraser> phrasersList);


}