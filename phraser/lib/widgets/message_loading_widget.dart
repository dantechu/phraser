import 'package:flutter/material.dart';
import 'package:phraser/consts/colors.dart';
import 'package:phraser/widgets/loading_widget.dart';

class MessageBoxLoadingWidget extends StatefulWidget {
  const MessageBoxLoadingWidget({this.containerGradient});
  final List<String>? containerGradient;

  @override
  State<MessageBoxLoadingWidget> createState() => _MessageBoxLoadingWidgetState();
}

class _MessageBoxLoadingWidgetState extends State<MessageBoxLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.only(left: 20, top: 25, bottom: 25, right: 25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                    colors:
                        widget.containerGradient?.map((e) => Color(int.parse(e))).toList() ?? AppColors.linearGradientAiChatBox,
                    begin: Alignment.topLeft)),
            child:  Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Thinking ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                    SizedBox(width: 5),
                    WaveLoadingWidget(size: 7, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
