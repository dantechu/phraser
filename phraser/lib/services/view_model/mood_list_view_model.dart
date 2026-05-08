import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../floor_db/moods_dao.dart';
import '../../util/Floor_db.dart';
import '../../util/constant_urls.dart';
import '../../util/utils.dart';
import '../model/mood_api_model.dart';
import '../model/mood_entity.dart';

class MoodListViewModel extends GetxController {
  bool isMoodsLoading = false;
  List<MoodItem> currentMoodsList = [];
  String? errorMessage;

  void updateLoadingState(bool state) {
    isMoodsLoading = state;
    update();
  }

  // Main method to get moods - checks DB first, then API
  Future<void> getMoods() async {
    updateLoadingState(true);
    errorMessage = null;

    try {
      // Try to load from database first (if it exists)
      try {
        final database = FloorDB.instance.floorDatabase;
        MoodsDAO moodsDAO = database.moodsDAO;
        final localMoods = await moodsDAO.getAllMoods();

        if (localMoods.isNotEmpty) {
          testPrint('✅ Loading moods from local database: ${localMoods.length}');
          currentMoodsList = localMoods.map((entity) => entity.toMoodItem()).toList();
          updateLoadingState(false);
          return;
        }
      } catch (dbError) {
        testPrint('⚠️ Database not ready, fetching from API: $dbError');
      }

      // Fetch from API
      await fetchMoodsFromApi();
    } catch (e, stackTrace) {
      testPrint('❌ getMoods() Exception: $e');
      testPrint('Stack trace: $stackTrace');
      errorMessage = 'Failed to load moods. Please try again.';
      updateLoadingState(false);
    }
  }

  // Fetch moods from API and save to database
  Future<void> fetchMoodsFromApi() async {
    try {
      testPrint('📡 Fetching moods from: ${ConstantURls.kGetMoods}');
      var response = await Dio().get(ConstantURls.kGetMoods);
      testPrint('📡 API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        testPrint('📦 API raw response: ${response.data}');
        MoodApiModel moodApiModel = MoodApiModel.fromJson(response.data);
        currentMoodsList = moodApiModel.moods;
        testPrint('✅ Loaded ${currentMoodsList.length} moods from API');

        // Debug: Print first mood details
        if (currentMoodsList.isNotEmpty) {
          final firstMood = currentMoodsList.first;
          testPrint('🎭 First mood - ID: ${firstMood.moodId}, Title: ${firstMood.moodTitle}, Icon: "${firstMood.moodIcon}"');
        }

        // Save to local database
        await saveMoodsToDatabase(currentMoodsList);

        updateLoadingState(false);
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      testPrint('❌ fetchMoodsFromApi() Exception: $e');
      testPrint('Stack trace: $stackTrace');
      errorMessage = 'Failed to load moods. Please try again.';
      updateLoadingState(false);
      rethrow; // Re-throw to be caught by getMoods()
    }
  }

  // Save moods to local database
  Future<void> saveMoodsToDatabase(List<MoodItem> moods) async {
    try {
      final database = FloorDB.instance.floorDatabase;
      MoodsDAO moodsDAO = database.moodsDAO;

      // Convert MoodItem to MoodEntity
      final moodEntities = moods.map((item) => MoodEntity.fromMoodItem(item)).toList();

      // Insert into database
      await moodsDAO.insertAllMoods(moodEntities);
      testPrint('Saved ${moodEntities.length} moods to local database');
    } catch (e) {
      testPrint('saveMoodsToDatabase() Exception (database may not be ready): $e');
      // Don't throw error - moods are already loaded from API
    }
  }

  // Force refresh moods from API (optional - for pull to refresh)
  Future<void> refreshMoodsFromApi() async {
    try {
      updateLoadingState(true);
      errorMessage = null;

      // Clear existing moods from database
      final database = FloorDB.instance.floorDatabase;
      MoodsDAO moodsDAO = database.moodsDAO;
      await moodsDAO.deleteAllMoods();

      // Fetch fresh data from API
      await fetchMoodsFromApi();
    } catch (e) {
      testPrint('refreshMoodsFromApi() Exception: $e');
      errorMessage = 'Failed to refresh moods. Please try again.';
      updateLoadingState(false);
    }
  }
}
