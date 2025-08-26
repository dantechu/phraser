library ai_interactions;

import 'package:ai_interactions/contollers/ai_interactions_controller.dart';
import 'package:ai_interactions/services/interaction_logger_service.dart';
import 'package:ai_interactions/services/open_ai_service.dart';
import 'package:ai_interactions/usecases/ai_interactions_usecases.dart';
import 'package:ai_interactions/usecases/interactions_history_usecases.dart';
import 'package:core/core.dart';

//Package Exports
export 'package:ai_interactions/examples/ai_interaction_example.dart';
export 'package:ai_interactions/usecases/ai_interactions_usecases.dart';
export 'package:ai_interactions/contollers/ai_interactions_controller.dart';
export 'package:ai_interactions/models/message_datamodel.dart';
export 'package:ai_interactions/models/logged_interactions_model.dart';

///Register in your app's main or location where needed before using this package
class AIInteractionsPackage {
  AIInteractionsPackage.registerDependencies() {
    Get.put(InteractionsHistoryUseCases(InteractionLoggerService()), permanent: true);

    Get.put(AIInteractionsUseCases(OpenAIService()), permanent: true);

    Get.put(AIInteractionsController(), permanent: true);
  }
}
