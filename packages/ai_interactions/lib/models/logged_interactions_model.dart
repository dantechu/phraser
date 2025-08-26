import 'package:core/core.dart';

part 'logged_interactions_model.g.dart';

//Name of Hive DB
const appInteractionsHistoryDB = 'AppInteractionsHistoryDB';

@HiveType(typeId: 2)
class LoggedInteractionsModel {
  LoggedInteractionsModel(
      {required this.timestamp,
      required this.interactions,
      this.isDelete = false});

  @HiveField(1)
  String timestamp;

  @HiveField(2)
  List<InteractionModel> interactions;

  @HiveField(3)
  bool? isDelete;

}

@HiveType(typeId: 3)
class InteractionModel {
  InteractionModel({
    required this.chatID,
    required this.characterID,
    required this.usage,
    required this.prompt,
    required this.response,
    //timestamp in milliseconds
    required this.timestamp,
    required this.language
  });

  @HiveField(1)
  String chatID;

  @HiveField(2)
  String characterID;

  @HiveField(3)
  InteractionUsageModel usage;

  @HiveField(4)
  String prompt;

  @HiveField(5)
  String response;

  @HiveField(6)
  String? timestamp;

  @HiveField(7)
  String? language;

}

@HiveType(typeId: 4)
class InteractionUsageModel {
  InteractionUsageModel({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  @HiveField(1)
  int promptTokens;
  @HiveField(2)
  int completionTokens;
  @HiveField(3)
  int totalTokens;
}
