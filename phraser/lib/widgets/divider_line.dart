import 'package:flutter/material.dart';

class DividerLine extends StatelessWidget {
 const  DividerLine({Key? key, this.upperHeight, this.lowerHeight}) : super(key: key);

  final double? upperHeight;
  final double? lowerHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(height: upperHeight ?? 20.0),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 0.5,
            child: Container(
              color: Theme.of(context).primaryColorLight.withOpacity(0.5),
            ),
          ),
          SizedBox(height: lowerHeight ?? 10.0),
        ],
      ),
    );
  }
}
