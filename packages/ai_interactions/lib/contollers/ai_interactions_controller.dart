import 'package:ai_interactions/models/ai_rc_datamodel.dart';
import 'package:ai_interactions/models/logged_interactions_model.dart';
import 'package:ai_interactions/models/message_datamodel.dart';
import 'package:ai_interactions/usecases/ai_interactions_usecases.dart';
import 'package:ai_interactions/usecases/interactions_history_usecases.dart';
import 'package:core/core.dart';

///A controller that stores chat messages in state for current session
///Run init() before any interaction
class AIInteractionsController extends GetxController {
  final _useCases = Get.find<AIInteractionsUseCases>();
  final _interactionHistoryUseCase = Get.find<InteractionsHistoryUseCases>();
  final List<MessageDataModel> _messages = [];

  ///Clears state _messages lists,
  ///sets Character/System Personality and
  ///fetches RC Configs if not already set
  Future<void> init({String characterPersonality = '', List<Map<String, dynamic>>? setInitialConversation}) async {
    _messages.clear();
    _messages.add(MessageDataModel(role: MessageRole.system, content: characterPersonality));

    for (final message in setInitialConversation ?? []) {
      _messages.add(
        MessageDataModel(
          role: message.keys.first == MessageRole.assistant.name ? MessageRole.assistant : MessageRole.user,
          content: message.values.first.toString(),
        ),
      );
    }
  }

  Future<Result<MessageDataModel, Object>> fetchAIResponse(MessageDataModel message, String characterId, String? language) async {
    _messages.add(message);
    final configs = AIRemoteConfigDataModel.fromJson({
      "base_url": "https://api.openai.com/v1/chat/completions",
      "api_key": characterId,
      "api_model": "gpt-3.5-turbo",
      "content_type": "application/json",
      "language": 'en'
    });
    final response = await _useCases.fetchAIResponse(configs: configs, messages: _messages);

    if (response.isSuccess) {
      await Get.find<InteractionsHistoryUseCases>()
          .logInteractionLocally(prompt: _messages.last, responseModel: response.success, characterId: characterId, language: language ?? 'en');

      final firstChoice = response.success.choices.first.message;

      _messages.add(firstChoice);
      return Success(firstChoice);
    } else {
      return Failure(response.failure);
    }
  }

  Future<List<LoggedInteractionsModel>> getLocalHistory() async {
    return _interactionHistoryUseCase.getLocalHistory();
  }
}
