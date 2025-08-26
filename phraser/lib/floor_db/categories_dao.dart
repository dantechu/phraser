
import 'package:floor/floor.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/util/constant_strings.dart';

@dao
abstract class CategoriesDAO {

  @Query('SELECT * FROM ${ConstantStrings.kCategoriesTableName}')
  Future<List<Categories>> getAllCategories();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllCategories(List<Categories> categories);

  // @Query('SELECT * FROM ${ConstantStrings.kCategoriesTableName} WHERE category_section = :category_section')
  // Stream<List<Categories>?> getCategoriesBySection(String category_section);

  @Query('DELETE FROM ${ConstantStrings.kCategoriesTableName}')
  Future<void> deleteAllCategories();
}