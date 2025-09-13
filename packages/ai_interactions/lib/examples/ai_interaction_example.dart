import 'package:ai_interactions/ai_interactions.dart';
import 'package:ai_interactions/usecases/interactions_history_usecases.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class AIInteractionExample extends StatefulWidget {
  const AIInteractionExample({Key? key}) : super(key: key);

  static const String routeName = '/aiInteractionExample';

  @override
  State<AIInteractionExample> createState() => _AIInteractionExampleState();
}

class _AIInteractionExampleState extends State<AIInteractionExample> {
  late Future<void> initFuture;

  @override
  void initState() {
    //insert dependencies on init
    AIInteractionsPackage.registerDependencies();

    //fetch configs and assign personality to the system
    initFuture = Get.find<AIInteractionsController>()
        .init(characterPersonality: 'You are a stupid assistant whose answers are always wrong.', setInitialConversation: []);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: context.percentHeight * 60,
          child: Column(
            children: [
              _fetchAiResponse(),
              TextButton(
                  onPressed: () async {
                    final history = await Get.find<InteractionsHistoryUseCases>().getLocalHistory();
                    // ignore: use_build_context_synchronously
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('Back'))
                              ],
                              title: const Text('See Last Interaction prompt and response'),
                              content: SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                width: MediaQuery.of(context).size.width / 2,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: history.length,
                                    itemBuilder: (_, index) {
                                      return Text(
                                        '${history[index].timestamp} -- ${history[index].interactions.last.characterID} -- ${history[index].interactions.last.prompt} -- ${history[index].interactions.last.response} -- ${history[index].interactions.length}',
                                        style: const TextStyle(color: Colors.white),
                                      );
                                    }),
                              ),
                            ));
                  },
                  child: const Text('See History'))
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<Result<MessageDataModel, Exception>> _fetchAiResponse() {
    return FutureBuilder(
      future: Get.find<AIInteractionsController>().fetchAIResponse(
          //send a dummy message to the AI
          MessageDataModel(role: MessageRole.user, content: 'How to fly?'),
          '', 'en'),
      builder: (__, snapshot2) {
        if (snapshot2.hasData && snapshot2.data != null) {
          if (snapshot2.data!.isSuccess) {
            return Text("{${snapshot2.data!.success.role} -- ${snapshot2.data!.success.content}}");
          }

          return Text('snapshot2 :: ${snapshot2.data!.failure}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
