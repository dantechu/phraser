import 'package:floor/floor.dart';
import '../services/model/mood_entity.dart';
import '../util/constant_strings.dart';

@dao
abstract class MoodsDAO {
  @Query('SELECT * FROM ${ConstantStrings.kMoodsTableName}')
  Future<List<MoodEntity>> getAllMoods();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllMoods(List<MoodEntity> moods);

  @Query('DELETE FROM ${ConstantStrings.kMoodsTableName}')
  Future<void> deleteAllMoods();

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kMoodsTableName}')
  Future<int?> getMoodsCount();
}
