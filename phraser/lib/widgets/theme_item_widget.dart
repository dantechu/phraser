import 'package:flutter/material.dart';

import 'divider_line.dart';

class ThemeItemWidget extends StatelessWidget {
  const ThemeItemWidget({Key? key, required this.title, required this.onTap, required this.isActiveItem})
      : super(key: key);

  final String title;
  final Function onTap;
  final bool isActiveItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
                if(isActiveItem)
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.check_circle_outline_sharp,
                    size:28,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            DividerLine(
              upperHeight: 0.0,
              lowerHeight: 0.0,
            )
          ],
        ),
      ),
    );
  }
}
