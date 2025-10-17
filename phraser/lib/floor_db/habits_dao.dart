import 'package:floor/floor.dart';
import '../services/model/habit_model.dart';
import '../util/constant_strings.dart';

@dao
abstract class HabitsDAO {
  // Create
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertHabit(Habit habit);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllHabits(List<Habit> habits);

  // Read
  @Query('SELECT * FROM ${ConstantStrings.kHabitsTableName} WHERE habitId = :habitId')
  Future<Habit?> getHabitById(String habitId);

  @Query('SELECT * FROM ${ConstantStrings.kHabitsTableName} WHERE isActive = 1 ORDER BY createdAt DESC')
  Future<List<Habit>> getAllActiveHabits();

  @Query('SELECT * FROM ${ConstantStrings.kHabitsTableName} ORDER BY createdAt DESC')
  Future<List<Habit>> getAllHabits();

  @Query('SELECT * FROM ${ConstantStrings.kHabitsTableName} WHERE category = :category AND isActive = 1')
  Future<List<Habit>> getHabitsByCategory(String category);

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kHabitsTableName} WHERE isActive = 1')
  Future<int?> getActiveHabitsCount();

  // Update
  @Query('UPDATE ${ConstantStrings.kHabitsTableName} SET isActive = :isActive, updatedAt = :updatedAt WHERE habitId = :habitId')
  Future<void> updateHabitActiveStatus(String habitId, bool isActive, String updatedAt);

  @Query('UPDATE ${ConstantStrings.kHabitsTableName} SET targetValue = :targetValue, updatedAt = :updatedAt WHERE habitId = :habitId')
  Future<void> updateHabitTarget(String habitId, int targetValue, String updatedAt);

  // Delete
  @Query('DELETE FROM ${ConstantStrings.kHabitsTableName} WHERE habitId = :habitId')
  Future<void> deleteHabit(String habitId);

  @Query('DELETE FROM ${ConstantStrings.kHabitsTableName}')
  Future<void> deleteAllHabits();

  // Deactivate all habits (for resetting)
  @Query('UPDATE ${ConstantStrings.kHabitsTableName} SET isActive = 0, updatedAt = :updatedAt')
  Future<void> deactivateAllHabits(String updatedAt);
}
