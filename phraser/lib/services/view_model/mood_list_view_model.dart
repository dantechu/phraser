import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../util/constant_urls.dart';
import '../../util/utils.dart';
import '../model/mood_api_model.dart';

class MoodListViewModel extends GetxController {
  bool isMoodsLoading = false;
  List<MoodItem> currentMoodsList = [];
  String? errorMessage;

  void updateLoadingState(bool state) {
    isMoodsLoading = state;
    update();
  }

  Future<void> getMoods() async {
    try {
      updateLoadingState(true);
      errorMessage = null;

      var response = await Dio().get(ConstantURls.kGetMoods);
      testPrint('Moods API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        testPrint('Moods API raw response: ${response.data}');
        MoodApiModel moodApiModel = MoodApiModel.fromJson(response.data);
        currentMoodsList = moodApiModel.moods;
        testPrint('Moods loaded: ${currentMoodsList.length}');

        // Debug: Print first mood details
        if (currentMoodsList.isNotEmpty) {
          final firstMood = currentMoodsList.first;
          testPrint('First mood - ID: ${firstMood.moodId}, Title: ${firstMood.moodTitle}, Icon: "${firstMood.moodIcon}"');
        }

        updateLoadingState(false);
      } else {
        throw Exception('Failed to load moods data!');
      }
    } catch (e) {
      testPrint('getMoods() Exception: $e');
      errorMessage = 'Failed to load moods. Please try again.';
      updateLoadingState(false);
    }
  }
}
