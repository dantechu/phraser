import 'package:ai_interactions/models/message_datamodel.dart';

class AIResponseDataModel {
  final String id;
  final String object;
  final int created;
  final String model;
  final Usage usage;
  final List<Choice> choices;

  AIResponseDataModel({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.usage,
    required this.choices,
  });

  factory AIResponseDataModel.fromJson(Map<String, dynamic> json) {
    var choicesList = json['choices'] as List;
    List<Choice> choices =
        choicesList.map((choice) => Choice.fromJson(choice)).toList();
    return AIResponseDataModel(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      usage: Usage.fromJson(json['usage']),
      choices: choices,
    );
  }
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}

class Choice {
  final MessageDataModel message;
  final String finishReason;
  final int index;

  Choice({
    required this.message,
    required this.finishReason,
    required this.index,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      message: MessageDataModel.fromJson(json['message']),
      finishReason: json['finish_reason'],
      index: json['index'],
    );
  }
}
