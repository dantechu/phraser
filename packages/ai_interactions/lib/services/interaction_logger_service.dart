import 'package:ai_interactions/models/logged_interactions_model.dart';
import 'package:core/core.dart';

class InteractionLoggerService {
  Box<LoggedInteractionsModel>? _box;


  Future<void> init() async {
    Hive.registerAdapter(InteractionUsageModelAdapter());
    Hive.registerAdapter(InteractionModelAdapter());
    Hive.registerAdapter(LoggedInteractionsModelAdapter());
  }

  ///Interactions History in Local Hive DB
  Future<List<LoggedInteractionsModel>> getLocalHistory() async {
    final box = await _openBox();

    return box.values.toList();
  }

  ///Write Interactions in Local Hive DB
  Future<void> logHistoryLocally(LoggedInteractionsModel model) async {
    final box = await _openBox();

    //Search for today's history using timestamp. If not exists then add new chat to the Local DB.
    try {
      final listOfInteractions = box.values.toList();

      final element = listOfInteractions.firstWhere((element) => element.timestamp == model.timestamp);

      final index = listOfInteractions.indexOf(element);

      box.putAt(index, model);
    } catch (e) {
      box.add(model);
    }
  }

  ///Clear Local Hive DB History.
  ///Typical usage, when user taps on clear History
  Future<void> clearChatHistory() async {
    final box = await _openBox();

    box.clear();
  }

  Future<Box<LoggedInteractionsModel>> _openBox() async {
    return _box ??= await Hive.openBox<LoggedInteractionsModel>(appInteractionsHistoryDB);
  }
}
