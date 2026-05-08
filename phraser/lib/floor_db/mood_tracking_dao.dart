import 'package:floor/floor.dart';
import '../services/model/mood_model.dart';
import '../util/constant_strings.dart';

@dao
abstract class MoodTrackingDAO {
  // Insert and Update Operations
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMoodEntry(MoodEntry entry);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMoodEntries(List<MoodEntry> entries);

  @Update()
  Future<void> updateMoodEntry(MoodEntry entry);

  // Query Operations - Basic
  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getAllMoodEntries();

  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE moodId = :moodId')
  Future<MoodEntry?> getMoodEntryById(String moodId);

  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE date = :date ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesByDate(String date);

  // Query Operations - Date Range
  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE date BETWEEN :startDate AND :endDate ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesInDateRange(String startDate, String endDate);

  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE date >= :startDate ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesSinceDate(String startDate);

  // Query Operations - Mood Type
  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE mood = :mood ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesByType(String mood);

  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE mood = :mood AND date BETWEEN :startDate AND :endDate ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesByTypeInRange(String mood, String startDate, String endDate);

  // Query Operations - Intensity
  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE intensity = :intensity ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesByIntensity(String intensity);

  // Query Operations - Statistics
  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kMoodTrackingTableName}')
  Future<int?> getTotalMoodEntriesCount();

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kMoodTrackingTableName} WHERE date BETWEEN :startDate AND :endDate')
  Future<int?> getMoodEntriesCountInRange(String startDate, String endDate);

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kMoodTrackingTableName} WHERE mood = :mood')
  Future<int?> getMoodTypeCount(String mood);

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kMoodTrackingTableName} WHERE mood = :mood AND date BETWEEN :startDate AND :endDate')
  Future<int?> getMoodTypeCountInRange(String mood, String startDate, String endDate);

  @Query('SELECT COUNT(*) FROM ${ConstantStrings.kMoodTrackingTableName} WHERE date = :date')
  Future<int?> getMoodEntriesCountForDate(String date);

  // Query Operations - Latest Entry
  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} ORDER BY timestamp DESC LIMIT 1')
  Future<MoodEntry?> getLatestMoodEntry();

  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE date = :date ORDER BY timestamp DESC LIMIT 1')
  Future<MoodEntry?> getLatestMoodEntryForDate(String date);

  // Query Operations - Distinct Values
  @Query('SELECT DISTINCT mood FROM ${ConstantStrings.kMoodTrackingTableName} ORDER BY mood')
  Future<List<String>> getDistinctMoodTypes();

  @Query('SELECT DISTINCT date FROM ${ConstantStrings.kMoodTrackingTableName} ORDER BY date DESC')
  Future<List<String>> getDistinctDates();

  // Query Operations - Notes and Triggers
  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE notes IS NOT NULL AND notes != "" ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesWithNotes();

  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} WHERE triggers IS NOT NULL AND triggers != "" ORDER BY timestamp DESC')
  Future<List<MoodEntry>> getMoodEntriesWithTriggers();

  // Delete Operations
  @Query('DELETE FROM ${ConstantStrings.kMoodTrackingTableName} WHERE moodId = :moodId')
  Future<void> deleteMoodEntry(String moodId);

  @Query('DELETE FROM ${ConstantStrings.kMoodTrackingTableName} WHERE date < :date')
  Future<void> deleteMoodEntriesBeforeDate(String date);

  @Query('DELETE FROM ${ConstantStrings.kMoodTrackingTableName}')
  Future<void> deleteAllMoodEntries();

  // Advanced Query - Get last N entries
  @Query('SELECT * FROM ${ConstantStrings.kMoodTrackingTableName} ORDER BY timestamp DESC LIMIT :limit')
  Future<List<MoodEntry>> getRecentMoodEntries(int limit);

  // Advanced Query - Streak calculation support
  @Query('SELECT DISTINCT date FROM ${ConstantStrings.kMoodTrackingTableName} ORDER BY date DESC')
  Future<List<String>> getAllDatesWithEntries();
}
