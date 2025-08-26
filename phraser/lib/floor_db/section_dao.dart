
import 'package:floor/floor.dart';
import 'package:phraser/services/model/category_sections.dart';
import 'package:phraser/util/constant_strings.dart';

@dao
abstract class SectionDAO {

  @Query('SELECT * FROM ${ConstantStrings.kSectionTableName}')
  Future<List<CategorySections>> getAllSection();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllSections(List<CategorySections> sectionList);

}