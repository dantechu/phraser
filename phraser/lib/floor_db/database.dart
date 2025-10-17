import 'dart:async';
import 'package:floor/floor.dart';
import 'package:phraser/floor_db/categories_dao.dart';
import 'package:phraser/floor_db/favorites_dao.dart';
import 'package:phraser/floor_db/moods_dao.dart';
import 'package:phraser/floor_db/phrasers_dao.dart';
import 'package:phraser/floor_db/section_dao.dart';
import 'package:phraser/floor_db/habits_dao.dart';
import 'package:phraser/floor_db/habit_progress_dao.dart';
import 'package:phraser/floor_db/habit_streak_dao.dart';
import 'package:phraser/services/model/categories.dart';
import 'package:phraser/services/model/category_sections.dart';
import 'package:phraser/services/model/mood_entity.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/services/model/habit_model.dart';
import 'package:phraser/services/model/habit_progress_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'current_phraser_dao.dart';
part 'database.g.dart';

@Database(version: 5, entities:[Categories, CategorySections, Phraser,Phraser,Phraser, MoodEntity, Habit, HabitProgress, HabitStreak])
abstract class AppDatabase extends FloorDatabase {

  CategoriesDAO get categoriesDAO;
  SectionDAO get sectionDAO;
  PhrasersDAO get phraserDAO;
  CurrentPhrasersDAO get currentPhraserDAO;
  FavoritesDAO get favoritesDAO;
  MoodsDAO get moodsDAO;
  HabitsDAO get habitsDAO;
  HabitProgressDAO get habitProgressDAO;
  HabitStreakDAO get habitStreakDAO;

}