import 'package:ai_interactions/models/ai_response_datamodel.dart';
import 'package:ai_interactions/models/logged_interactions_model.dart';
import 'package:ai_interactions/models/message_datamodel.dart';
import 'package:ai_interactions/services/interaction_logger_service.dart';

class InteractionsHistoryUseCases {
  final InteractionLoggerService _service;

  InteractionsHistoryUseCases(this._service) {
    _service.init();
  }

  Future<void> logInteractionLocally({
    required MessageDataModel prompt,
    required AIResponseDataModel responseModel,
    required String characterId,
    required String language
  }) async {
    final datetime = DateTime.now();
    final timestamp = DateTime(datetime.year, datetime.month, datetime.day).millisecondsSinceEpoch.toString();

    final interaction = InteractionModel(
      chatID: responseModel.id,
      characterID: characterId,
      usage: InteractionUsageModel(
          promptTokens: responseModel.usage.promptTokens,
          completionTokens: responseModel.usage.completionTokens,
          totalTokens: responseModel.usage.totalTokens),
      prompt: prompt.content!,
      response: responseModel.choices.first.message.content!,
      timestamp: datetime.millisecondsSinceEpoch.toString(),
      language: language,
    );

    //Search for today's history using timestamp. If not exists then add new chat to the Local DB.
    try {
      final history = await getLocalHistory();

      final todaysHistory = history.firstWhere((element) => element.timestamp == timestamp);

      todaysHistory.interactions.add(interaction);

      _service.logHistoryLocally(todaysHistory);
    } catch (e) {
      //New Chat for today
      _service.logHistoryLocally(LoggedInteractionsModel(timestamp: timestamp, interactions: [interaction]));
    }
  }

  Future<List<LoggedInteractionsModel>> getLocalHistory() async => await _service.getLocalHistory();

  void clearChatHistory() {
    _service.clearChatHistory();
  }
}
