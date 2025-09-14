import 'package:ai_interactions/ai_interactions.dart';
import 'package:coins/usecases/coins_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
  final _aiInteraction = Get.find<AIInteractionsController>();
  final scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final CoinsUseCases _coinsUseCases = Get.find<CoinsUseCases>();
  
  // Animation controllers for enhanced UX
  late AnimationController _headerAnimationController;
  late AnimationController _inputAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _inputAnimation;
  
  // Enhanced state management
  bool _isTyping = false;
  List<String> _quickSuggestions = [];
  String _currentTypingText = '';
  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeQuickSuggestions();
    _setupTextControllerListener();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeData();
    });
  }
  
  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _inputAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutBack),
    );
    _inputAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inputAnimationController, curve: Curves.elasticOut),
    );
    
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _inputAnimationController.forward();
    });
  }
  
  void _initializeQuickSuggestions() {
    _quickSuggestions = [
      '💪 Strength',
      '🌟 Success', 
      '❤️ Love',
      '🎯 Focus',
      '☮️ Peace',
      '💡 Wisdom',
      '🚀 Growth',
      '🌈 Hope',
    ];
  }
  
  void _setupTextControllerListener() {
    _textController.addListener(() {
      final text = _textController.text;
      if (text != _currentTypingText) {
        setState(() {
          _currentTypingText = text;
          _isTyping = text.isNotEmpty;
          _showSuggestions = text.isEmpty;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _headerAnimationController.dispose();
    _inputAnimationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with Animation
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - _headerAnimation.value)),
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: _buildEnhancedHeader(context),
                  ),
                );
              },
            ),
            
            // Chat Messages Area
            Expanded(
              child: GetBuilder<ChatViewModel>(
                builder: (viewModel) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            // Welcome Message or Chat History
                            if (chatViewModel.localHistory.isEmpty) ...[
                              _buildWelcomeMessage(),
                              const SizedBox(height: 20),
                              if (_showSuggestions) _buildQuickSuggestions(),
                            ] else ...[
                              ...chatViewModel.localHistory.map((history) {
                                return Column(
                                  children: [
                                    ...history.interactions.map((chat) {
                                      return FutureBuilder(
                                        initialData: false,
                                        future: Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () => true
                                        ),
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
                                                  containerGradient: const ["0XFFEB508D", "0XFF9D325C"],
                                                  userText: chat.prompt,
                                                  characterText: chat.response,
                                                  timeStamp: chat.timestamp!,
                                                ),
                                              ],
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      );
                                    }),
                                  ]
                                );
                              }),
                            ],
                            
                            // Current User Message (when busy)
                            if (viewModel.viewState == ViewState.busy && 
                                chatViewModel.userPrompt.isNotEmpty) ...[
                              ConversationBox(
                                role: MessageRole.user,
                                timeStamp: '',
                                userText: chatViewModel.userPrompt,
                              ),
                              const SizedBox(height: 8),
                            ],
                            
                            // Enhanced Loading Indicator
                            if (viewModel.viewState == ViewState.busy) ...[
                              _buildEnhancedLoadingIndicator(),
                              const SizedBox(height: 20),
                            ],
                            
                            // Error State with Retry
                            if (!viewModel.isResponseRecieved && 
                                viewModel.userPrompt.isNotEmpty) ...[
                              _buildErrorRetrySection(),
                              const SizedBox(height: 20),
                            ],
                            
                            // Add some bottom padding for better scrolling
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Enhanced Input Area
            AnimatedBuilder(
              animation: _inputAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _inputAnimation.value)),
                  child: Opacity(
                    opacity: _inputAnimation.value,
                    child: _buildEnhancedInputArea(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  // Clean and Simple Header Widget
  Widget _buildEnhancedHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Quotes Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  chatViewModel.viewState == ViewState.busy 
                      ? 'Thinking...' 
                      : 'Online',
                  style: TextStyle(
                    color: chatViewModel.viewState == ViewState.busy 
                        ? Colors.orange 
                        : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simple Welcome Message
  Widget _buildWelcomeMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🤖',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'Welcome to AI Quotes Assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type any word and I\'ll give you inspiring quotes about it',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Simple Quick Suggestions Widget
  Widget _buildQuickSuggestions() {
    return Column(
      children: [
        Text(
          'Try these popular themes:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickSuggestions.take(6).map((suggestion) {
            return _buildSuggestionChip(suggestion);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _textController.text = suggestion.split(' ').last; // Remove emoji
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          suggestion,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Simple Loading Indicator
  Widget _buildEnhancedLoadingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: MessageBoxLoadingWidget(
        containerGradient: ["0XFFEB508D", "0XFF9D325C"],
      ),
    );
  }

  // Error Retry Section
  Widget _buildErrorRetrySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Don\'t worry, let\'s try that again!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();
              if (chatViewModel.userPrompt.isNotEmpty) {
                final int availableCoins = await _coinsUseCases.getAvailableCoins();
                if (availableCoins > 1 || Preferences.instance.isPremiumApp) {
                  await _callOpenAi();
                } else {
                  Get.to(const PremiumAppScreen());
                }
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Clean Input Area
  Widget _buildEnhancedInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: _isTyping 
                      ? Border.all(color: AppColors.primaryColor, width: 1)
                      : Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: const TextStyle(fontSize: 16),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a word for inspiration...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _textController.text.isNotEmpty
                    ? AppColors.primaryColor
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _textController.text.isNotEmpty ? _sendMessage : null,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Send message method
  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;
    
    HapticFeedback.lightImpact();
    _focusNode.unfocus();
    
    final int availableCoins = await _coinsUseCases.getAvailableCoins();
    if (availableCoins >= 1 || Preferences.instance.isPremiumApp) {
      await _callOpenAi();
    } else {
      Get.to(const PremiumAppScreen());
    }
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
    // Set busy state with enhanced UX
    chatViewModel.viewState = ViewState.busy;
    chatViewModel.userPrompt = _textController.text.trim(); // Store original user input
    
    // Smooth scroll to bottom with delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollToBottom();
    });

    final originalUserInput = _textController.text.trim(); // Keep original input
    _textController.clear();
    
    // Create enhanced prompt in background (user won't see this)
    final enhancedPrompt = _createEnhancedPrompt(originalUserInput);
    
    try {
      // Add haptic feedback for professional feel
      HapticFeedback.mediumImpact();
      
      // Use enhanced prompt for AI but we'll modify the display later
      final result = await _aiInteraction.fetchAIResponse(
        MessageDataModel(role: MessageRole.user, content: enhancedPrompt), // Enhanced for better AI response
        updateString(AppConfigService.instance.adminPanelID),
        ''
      );

      if (result.isSuccess) {
        // Success feedback
        HapticFeedback.lightImpact();
        await _coinsUseCases.consumeCoins(1);
        chatViewModel.isResponseRecieved = true;
        
        // Update suggestions based on successful interaction
        _updateSuggestionsBasedOnInput(originalUserInput);
        
      } else {
        // Error feedback
        HapticFeedback.heavyImpact();
        chatViewModel.isResponseRecieved = false;
        debugPrint('AI Response failed: Unknown error');
      }

    } catch (e) {
      // Handle network or other errors
      HapticFeedback.heavyImpact();
      chatViewModel.isResponseRecieved = false;
      debugPrint('Exception in _callOpenAi: $e');
    }

    // Reset state
    chatViewModel.viewState = ViewState.idle;
    
    // Refresh chat history with improved timing
    await Future.delayed(const Duration(milliseconds: 100));
    chatViewModel.localHistory = await _aiInteraction.getLocalHistory();
    
    // Replace the enhanced prompt in chat history with original user input
    if (chatViewModel.isResponseRecieved) {
      _replaceLastUserMessageWithOriginal(originalUserInput);
    }

    // Enhanced scroll to bottom
    await Future.delayed(const Duration(milliseconds: 300));
    _scrollToBottom();

    // Show ads with better timing and error handling
    _handleAdDisplay();
  }

  /// Creates enhanced prompts for better AI responses (hidden from user)
  String _createEnhancedPrompt(String userInput) {
    final timeOfDay = _getTimeOfDayContext();
    
    return '''You are an inspiring AI quotes assistant. The user asked for quotes about "$userInput".

Please provide 2-3 beautiful, inspiring quotes about "$userInput" that are:
- Uplifting and positive
- Include the word "$userInput" naturally
- Feel personal and meaningful

$timeOfDay

Format each quote clearly with attribution. End with a brief encouraging message about how "$userInput" can positively impact their day.''';
  }

  /// Get appropriate context based on time of day
  String _getTimeOfDayContext() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Since it\'s morning, make the quotes extra motivational to start their day right.';
    } else if (hour < 17) {
      return 'It\'s afternoon - provide energizing quotes that can refocus them.';
    } else if (hour < 21) {
      return 'Evening time - offer wisdom that reflects on growth and achievement.';
    } else {
      return 'Late evening - share calming yet inspiring thoughts for reflection.';
    }
  }

  /// Update suggestions based on user interactions
  void _updateSuggestionsBasedOnInput(String input) {
    // Smart suggestion updates based on user interest
    final newSuggestions = <String>[
      '💪 Strength',
      '🌟 ${input.toLowerCase().contains('success') ? 'Achievement' : 'Success'}',
      '❤️ ${input.toLowerCase().contains('love') ? 'Compassion' : 'Love'}',
      '🎯 Focus',
      '☮️ Peace',
      '💡 Wisdom',
      '🚀 Growth',
      '🌈 ${input.toLowerCase().contains('hope') ? 'Dreams' : 'Hope'}',
    ];
    
    setState(() {
      _quickSuggestions = newSuggestions;
    });
  }

  /// Smooth scroll to bottom
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Handle ad display with better error handling
  void _handleAdDisplay() async {
    try {
      final int availableCoins = await _coinsUseCases.getAvailableCoins();
      
      // Show ads less frequently for better UX
      if (availableCoins % 3 == 0 && AdsHelper.freeTriesInterstitialAd != null) {
        await Future.delayed(const Duration(milliseconds: 1500));
        await AdsHelper.freeTriesInterstitialAd!.show();
      }
    } catch (e) {
      debugPrint('Error displaying interstitial ad: $e');
    }
  }

  /// Replace the enhanced prompt with original user input in chat history
  void _replaceLastUserMessageWithOriginal(String originalInput) {
    try {
      if (chatViewModel.localHistory.isNotEmpty) {
        final lastHistory = chatViewModel.localHistory.last;
        if (lastHistory.interactions.isNotEmpty) {
          final lastInteraction = lastHistory.interactions.last;
          
          // Create a modified interaction with the original user input
          lastInteraction.prompt = originalInput;
          
          // Update the chat view model to reflect changes
          setState(() {
            chatViewModel.localHistory = List.from(chatViewModel.localHistory);
          });
        }
      }
    } catch (e) {
      debugPrint('Error replacing user message: $e');
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


