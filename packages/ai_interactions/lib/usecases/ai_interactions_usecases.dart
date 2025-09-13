import 'package:ai_interactions/models/ai_rc_datamodel.dart';
import 'package:ai_interactions/models/ai_response_datamodel.dart';
import 'package:ai_interactions/models/message_datamodel.dart';
import 'package:ai_interactions/services/open_ai_service.dart';
import 'package:core/core.dart';

class AIInteractionsUseCases {
  final OpenAIService service;
  AIInteractionsUseCases(this.service);

  Future<Result<AIResponseDataModel, Exception>> fetchAIResponse(
      {required AIRemoteConfigDataModel configs, required List<MessageDataModel> messages}) async {
    final response = await service.fetchAIResponse(configs: configs, messages: _sendOldLastTenMessages(messages));

    if (response.isSuccess) {
      return Success(response.success);
    } else {
      return Failure(Exception(response.failure.toString()));
    }
  }

  List<MessageDataModel> _sendOldLastTenMessages(List<MessageDataModel> messages) {
    List<MessageDataModel> tempMessageList = [];

    ///if old messages length is greater than 10 conversation than send last 10 conversation to api.
    /// 1 conversation contains two messages one from user and one from assistant
    /// 10 conversation means 20 messages
    if (messages.length > 3) {
      messages = messages.reversed.toList();
      for (int i = 0; i < 3; i++) {
        messages[i].content = 'Based on your personality, generate random number of 10 to 15 short motivational quotes that includes the word ${messages[i].content}.Each new quote should start by skipping one new line';
        tempMessageList.add(messages[i]);
      }
      messages = messages.reversed.toList();
      tempMessageList.add(messages.first);
      tempMessageList = tempMessageList.reversed.toList();
      return tempMessageList;
    } else {
      return messages;
    }
  }
}
