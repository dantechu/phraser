
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Widget noteLeadingWidget(BuildContext context, {required IconData image, Color? color}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: boxDecorationDefault(shape: BoxShape.circle, color: context.cardColor),
    child: Icon(image, size: 21.0, color: color),
  );
}


Widget noteSwitchWidget({bool? noteSwitchValue, Function? onTap}) {
  return Transform.scale(
    scale: 0.8,
    child: CupertinoSwitch(
      value: noteSwitchValue!,
      activeColor: Colors.green,
      onChanged: (bool value) {
        onTap!.call(value);
      },
    ),
  );
}