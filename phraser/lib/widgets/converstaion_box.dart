import 'package:ai_interactions/ai_interactions.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phraser/consts/colors.dart';

class ConversationBox extends StatefulWidget {
  const ConversationBox({
    required this.timeStamp,
    required this.role,
    this.userText = "",
    this.characterText = "",
    this.characterShortName,
    this.containerGradient,
  });
  final MessageRole role;
  final String userText;
  final String characterText;
  final String timeStamp;
  final String? characterShortName;
  final List<String>? containerGradient;

  @override
  State<ConversationBox> createState() => _ConversationBoxState();
}

class _ConversationBoxState extends State<ConversationBox> with TickerProviderStateMixin {
  Animation<double?>? _animation;
  AnimationController? _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    if (_animationController != null) {
      _animation = Tween(begin: .3, end: 1.0).animate(_animationController!);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        _animation?.addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
        await _animationController?.forward();
      });
    }
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.role == MessageRole.user
        ? widget.userText.isEmpty
            ? const SizedBox()
            : Align(
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 20),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: AppColors.linearGradientMyChatBox,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  constraints: BoxConstraints(maxHeight: context.percentHeight * 100),
                                  child: Text(widget.userText, style: TextStyle(color: Colors.white),),
                                ),
                              ],
                            ),
                          ),
                          if (widget.timeStamp.isNotEmpty)
                            Positioned(
                                bottom: 8.0,
                                right: 8.0,
                                child: Text(
                                  '${_convertTimestampToTime(widget.timeStamp)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                )),
                        ],
                      ),
                    ),
                  ],
                ),
              )
        : widget.role == MessageRole.assistant
            ? Transform.scale(
                scale: _animation?.value ?? 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 30, bottom: 20),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              padding: const EdgeInsets.only(left: 20, top: 25, bottom: 25, right: 25),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                      colors: widget.containerGradient?.map((e) => Color(int.parse(e))).toList() ??
                                          AppColors.linearGradientAiChatBox,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight)),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText.rich(TextSpan(
                                      children: [
                                        TextSpan(
                                          text: widget.characterText.trim(),
                                        ),
                                      ],
                                      style: const TextStyle(color: Colors.white),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 8.0,
                                right: 8.0,
                                child: Text(
                                  _convertTimestampToTime(widget.timeStamp),
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox();
  }

  String _convertTimestampToTime(String timestamp) {
    return DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)));
  }
}
