import 'package:ai_interactions/ai_interactions.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phraser/consts/colors.dart';
import 'package:flutter/services.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return widget.role == MessageRole.user
        ? widget.userText.isEmpty
            ? const SizedBox()
            : _buildUserMessage(context, isDarkMode)
        : widget.role == MessageRole.assistant
            ? Transform.scale(
                scale: _animation?.value ?? 1,
                child: _buildAssistantMessage(context, isDarkMode),
              )
            : const SizedBox();
  }

  Widget _buildUserMessage(BuildContext context, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 60, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onLongPress: () => _copyToClipboard(widget.userText),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [const Color(0xFF2196F3), const Color(0xFF1976D2)]
                        : [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? Colors.blue : Colors.green).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.userText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (widget.timeStamp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Text(
                  _convertTimestampToTime(widget.timeStamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(BuildContext context, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.containerGradient?.map((e) => Color(int.parse(e))).toList() ??
                          (isDarkMode
                              ? [const Color(0xFF6C63FF), const Color(0xFF4C4CFF)]
                              : [const Color(0xFF667EEA), const Color(0xFF764BA2)]),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode ? Colors.purple : Colors.blue).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Message Content
                Expanded(
                  child: GestureDetector(
                    onLongPress: () => _copyToClipboard(widget.characterText),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2A2A2A)
                            : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SelectableText(
                        widget.characterText.trim(),
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey.shade100 : Colors.grey.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.timeStamp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 48),
                child: Text(
                  _convertTimestampToTime(widget.timeStamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    // Optional: Show a snackbar or toast to confirm copy
  }

  String _convertTimestampToTime(String timestamp) {
    return DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)));
  }
}
