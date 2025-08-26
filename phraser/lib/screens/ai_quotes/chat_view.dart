import 'package:ai_interactions/ai_interactions.dart';
import 'package:ai_interactions/contollers/ai_interactions_controller.dart';
import 'package:coins/usecases/coins_usecases.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phraser/ads/consts/ads_helper.dart';
import 'package:phraser/consts/colors.dart';
import 'package:phraser/screens/ai_quotes/view_model/chat_view_model.dart';
import 'package:phraser/screens/in_app_purchase/preimum_app_screen.dart';
import 'package:phraser/util/app_config_service.dart';
import 'package:phraser/util/preferences.dart';
import 'package:phraser/widgets/converstaion_box.dart';
import 'package:phraser/widgets/message_loading_widget.dart';


class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
  final _aiInteraction = Get.find<AIInteractionsController>();
  final scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final CoinsUseCases _coinsUseCases = Get.find<CoinsUseCases>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeData();
    });
  }

  Future<void> initializeData() async {
   chatViewModel.localHistory = await  _aiInteraction.getLocalHistory();
   // Scroll to the end of the list
   Future.delayed(const Duration(seconds: 1), () {
     scrollController.jumpTo(
       scrollController.position.maxScrollExtent,
     );

   });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Quotes Assistant'),
      ),
      body: Column(
        children: [
          GetBuilder<ChatViewModel>(
            builder: (viewModel) {
              return Expanded(
                child:  SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                            children: [
                              if (chatViewModel.localHistory.isNotEmpty) ...{
                                ...chatViewModel.localHistory.map(
                                      (history) {
                                    return Column(children: [
                                      ...history.interactions
                                          .map((chat) => true
                                          ? Visibility(
                                        visible: true,
                                        child: FutureBuilder(
                                            initialData: false,
                                            future: Future.delayed((const Duration(milliseconds: 300)), () => true),
                                            builder: (context, AsyncSnapshot<bool> snapshot) {
                                              if (snapshot.data == true) {
                                                return Column(
                                                  children: [
                                                       ConversationBox(
                                                        role: chatViewModel.viewState == ViewState.busy &&
                                                            chat.prompt == chatViewModel.userPrompt &&
                                                            _getDateTimeWithOutSeconds(chat.timestamp!)
                                                            ? MessageRole.system
                                                            : MessageRole.user,
                                                        timeStamp: chat.timestamp!,
                                                        userText: chat.prompt,
                                                      ),
                                                    ConversationBox(
                                                        role: chatViewModel.viewState == ViewState.busy &&
                                                            chat.prompt == chatViewModel.userPrompt &&
                                                            _getDateTimeWithOutSeconds(chat.timestamp!)
                                                            ? MessageRole.system
                                                            : MessageRole.assistant,
                                                        containerGradient: ["0XFFEB508D", "0XFF9D325C"],
                                                        userText: chat.prompt,
                                                        characterText: chat.response,
                                                        timeStamp: chat.timestamp!,
                                                      ),
                                                  ],
                                                );
                                              } else {
                                                return const SizedBox();
                                              }
                                            }),
                                      )
                                          : const SizedBox())
                                          .toList(),
                                    ]);
                                  },
                                ),
                              },
                              if(viewModel.localHistory.isEmpty) ...{
                                const ConversationBox(
                                  role: MessageRole.user,
                                  timeStamp: '',
                                  userText: '🌟Welcome to the AI Quotes Assistant! 🌟\n'
                                      '\nHello, lovely human! 😊 I\'m here to fill your day with warm, encouraging quotes. I specialize in positivity and silver linings.'
                                    '\n\n📝 How It Works? 📝\n'
                                    'Simply type a keyword—like "Courage" or "Success"—and I\'ll gift you an inspiring quote that includes it.'
                                '\n\n🎯 Quick Examples 🎯\n'
                                'Courage: Type for bravery boosters.'
                                '\nSuccess: Type for ambition fuel.'
                                '\n\nReady for a dose of optimism? Type your word! 😊',
                                ),
                              },
                              if ((viewModel.viewState == ViewState.busy) &&
                                  chatViewModel.userPrompt.isNotEmpty) ...{
                                ConversationBox(
                                  role: MessageRole.user,
                                  timeStamp: '',
                                  userText: chatViewModel.userPrompt,
                                ),
                              },
                              if (viewModel.viewState == ViewState.busy) ...{
                                const Align(
                                    alignment: Alignment.centerLeft,
                                    child: MessageBoxLoadingWidget(
                                      containerGradient: ["0XFFEB508D",
                                        "0XFF9D325C"],
                                    )),
                              },
                              if (!viewModel.isResponseRecieved && viewModel.userPrompt.isNotEmpty) ...{
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                     Expanded(
                                      child: Text(
                                        'Something went wrong Please',
                                        style: TextStyle(color: AppColors.primaryColor),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (chatViewModel.userPrompt.isNotEmpty) {
                                          final int availableCoins = await _coinsUseCases.getAvailableCoins();
                                          if(availableCoins >1 || Preferences.instance.isPremiumApp) {
                                            await _callOpenAi();
                                          } else {
                                            Get.to(const PremiumAppScreen());
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                                      child: const Text('Try Again'),
                                    )
                                  ],
                                )
                              }
                            ],
                          ),
                  ),
                ),

              );
            }
          ),
          Container(
            color: Theme.of(context).primaryColor,
            height: 80,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 12.0, bottom: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _textController,
                      style: TextStyle(fontSize: 17, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Type word to get quotes...',
                        hintStyle: TextStyle(color: Colors.blueGrey, fontSize: 17),
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // set rounded corner radius
                          borderSide: BorderSide.none, // hide default border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // set rounded corner radius
                          borderSide: BorderSide.none, // hide border on focus
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // set rounded corner radius
                          borderSide: BorderSide.none, // hide enabled border
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    decoration: const BoxDecoration(
                      color: Colors.white, // set background color to white
                      shape: BoxShape.circle, // set circular shape
                    ),
                    child: IconButton(
                      icon:  Icon(Icons.send, color: Colors.blueGrey),
                      onPressed: () async {
                        if (_textController.text.isNotEmpty) {
                          _focusNode.unfocus();
                          final int availableCoins = await _coinsUseCases.getAvailableCoins();
                          if(availableCoins >=1 || Preferences.instance.isPremiumApp) {
                            await _callOpenAi();
                          } else {
                            Get.to(const PremiumAppScreen());
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageRow(String message, CrossAxisAlignment alignment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: alignment == CrossAxisAlignment.start ? Colors.blue[100] : Colors.green[100],
            ),
            child: Text(message),
          ),
        ],
      ),
    );
  }


  Future _callOpenAi() async {
    chatViewModel.viewState = ViewState.busy;
    Future.delayed(const Duration(milliseconds: 500), () {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });
    final inputText = _textController.text.toString();
    _textController.clear();
    final result = await _aiInteraction.fetchAIResponse(
        MessageDataModel(role: MessageRole.user, content:  '$inputText'),updateString(AppConfigService.instance.adminPanelID),'');
    if (result.isSuccess) {
      await _coinsUseCases.consumeCoins(1);
      chatViewModel.isResponseRecieved = true;
    } else {
      chatViewModel.isResponseRecieved = false;
    }
    chatViewModel.viewState = ViewState.idle;
    Future.delayed(const Duration(milliseconds: 50), () async {
      chatViewModel.localHistory = await _aiInteraction.getLocalHistory();
    });

    // Scroll to the end of the list
    Future.delayed(const Duration(seconds: 1), () {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });
    final int availableCoins = await _coinsUseCases.getAvailableCoins();
    if( availableCoins%2 != 0 &&  AdsHelper.freeTriesInterstitialAd != null) {
      try {
        await Future.delayed(const Duration(seconds: 1), () {
          AdsHelper.freeTriesInterstitialAd!.show();
        });

      } catch (e) {
        debugPrint('---> Error in displaying interstitial on AI quotes screen.');
      }
    }

  }


  String updateString(String input) {
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      int charCode = input.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) {
        charCode = ((charCode - 65 + 13) % 26) + 65;
      } else if (charCode >= 97 && charCode <= 122) {
        charCode = ((charCode - 97 + 13) % 26) + 97;
      }
      result.writeCharCode(charCode);
    }
    return result.toString();
  }


  bool _getDateTimeWithOutSeconds(String timeStamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp));
    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute) ==
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute);
  }

}


