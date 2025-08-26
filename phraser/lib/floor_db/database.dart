import 'dart:async';
import 'package:floor/floor.dart';
import 'package:phraser/floor_db/categories_dao.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/floor_db/section_dao.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/services/model/category_sections.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'current_phraser_dao.dart';
part 'database.g.dart';

@Database(version: 1, entities:[Categories, CategorySections, Phraser, Phraser, Phraser])
abstract class AppDatabase extends FloorDatabase {

  CategoriesDAO get categoriesDAO;
  SectionDAO get sectionDAO;
  PhrasersDAO get phraserDAO;
  CurrentPhrasersDAO get currentPhraserDAO;
  FavoritesDAO get favoritesDAO;

}