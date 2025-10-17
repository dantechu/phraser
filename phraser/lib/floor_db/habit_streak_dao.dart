import 'package:floor/floor.dart';
import '../services/model/habit_progress_model.dart';
import '../util/constant_strings.dart';

@dao
abstract class HabitStreakDAO {
  // Create
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertStreak(HabitStreak streak);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllStreaks(List<HabitStreak> streaks);

  // Read
  @Query('SELECT * FROM ${ConstantStrings.kHabitStreakTableName} WHERE streakId = :streakId')
  Future<HabitStreak?> getStreakById(String streakId);

  @Query('SELECT * FROM ${ConstantStrings.kHabitStreakTableName} WHERE habitId = :habitId')
  Future<HabitStreak?> getStreakByHabitId(String habitId);

  @Query('SELECT * FROM ${ConstantStrings.kHabitStreakTableName} ORDER BY currentStreak DESC LIMIT :limit')
  Future<List<HabitStreak>> getTopStreaks(int limit);

  // Update
  @Query('UPDATE ${ConstantStrings.kHabitStreakTableName} SET currentStreak = :currentStreak, longestStreak = :longestStreak, lastCompletedDate = :lastCompletedDate, updatedAt = :updatedAt WHERE habitId = :habitId')
  Future<void> updateStreak(String habitId, int currentStreak, int longestStreak, String lastCompletedDate, String updatedAt);

  // Delete
  @Query('DELETE FROM ${ConstantStrings.kHabitStreakTableName} WHERE habitId = :habitId')
  Future<void> deleteStreakByHabitId(String habitId);

  @Query('DELETE FROM ${ConstantStrings.kHabitStreakTableName}')
  Future<void> deleteAllStreaks();
}
