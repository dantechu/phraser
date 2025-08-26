import 'package:ai_interactions/models/message_datamodel.dart';

class AIRequestModel {
  final String model;
  final List<MessageDataModel> messages;

  AIRequestModel({
    required this.model,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> messagesJson =
        messages.map((m) => m.toJson()).toList();
    return {
      'model': model,
      'messages': messagesJson,
    };
  }
}
