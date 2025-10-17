import 'package:floor/floor.dart';
import '../services/model/habit_progress_model.dart';
import '../util/constant_strings.dart';

@dao
abstract class HabitProgressDAO {
  // Create
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertProgress(HabitProgress progress);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllProgress(List<HabitProgress> progressList);

  // Read
  @Query('SELECT * FROM ${ConstantStrings.kHabitProgressTableName} WHERE progressId = :progressId')
  Future<HabitProgress?> getProgressById(String progressId);

  @Query('SELECT * FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId ORDER BY date DESC')
  Future<List<HabitProgress>> getProgressByHabitId(String habitId);

  @Query('SELECT * FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId AND date = :date')
  Future<HabitProgress?> getProgressByHabitAndDate(String habitId, String date);

  @Query('SELECT * FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId AND date >= :startDate AND date <= :endDate ORDER BY date DESC')
  Future<List<HabitProgress>> getProgressByDateRange(String habitId, String startDate, String endDate);

  @Query('SELECT * FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId AND isCompleted = 1 ORDER BY date DESC')
  Future<List<HabitProgress>> getCompletedProgressByHabitId(String habitId);

  @Query('SELECT * FROM ${ConstantStrings.kHabitProgressTableName} WHERE date = :date')
  Future<List<HabitProgress>> getProgressByDate(String date);

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId AND isCompleted = 1')
  Future<int?> getTotalCompletions(String habitId);

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId AND isCompleted = 1 AND date >= :startDate')
  Future<int?> getCompletionsAfterDate(String habitId, String startDate);

  // Get last 30 days completion rate
  @Query('SELECT * FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId AND date >= :startDate ORDER BY date DESC')
  Future<List<HabitProgress>> getRecentProgress(String habitId, String startDate);

  // Update
  @Query('UPDATE ${ConstantStrings.kHabitProgressTableName} SET completedValue = :completedValue, isCompleted = :isCompleted WHERE progressId = :progressId')
  Future<void> updateProgress(String progressId, int completedValue, bool isCompleted);

  // Delete
  @Query('DELETE FROM ${ConstantStrings.kHabitProgressTableName} WHERE progressId = :progressId')
  Future<void> deleteProgress(String progressId);

  @Query('DELETE FROM ${ConstantStrings.kHabitProgressTableName} WHERE habitId = :habitId')
  Future<void> deleteProgressByHabitId(String habitId);

  @Query('DELETE FROM ${ConstantStrings.kHabitProgressTableName}')
  Future<void> deleteAllProgress();
}
