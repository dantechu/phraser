
import 'dart:ui';

import 'package:flutter/material.dart';

class BackDropFilterWidget extends StatelessWidget {
  const BackDropFilterWidget({Key? key,  required this.child, this.isCancelable, this.onCloseButtonPressed}) : super(key: key);
  final Widget child;
  final bool? isCancelable;
  final Function? onCloseButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: Stack(
        children: [
          SafeArea(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
                child: child,
              )),
          if (isCancelable ?? true)
            Positioned(
                top: 0,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    onCloseButtonPressed != null ? onCloseButtonPressed?.call() : Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                ))
        ],
      ),
    );
  }
}