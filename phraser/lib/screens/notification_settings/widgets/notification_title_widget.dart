import 'package:flutter/material.dart';
import 'package:phraser/util/colors.dart';


class NotificationTitleWidget extends StatelessWidget {
  const NotificationTitleWidget({Key? key ,required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
      padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 15.0),
      decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0))
      ),
      child: Text(title, style: TextStyle(color: Colors.white, fontSize: 18, ),),
    );
  }
}
