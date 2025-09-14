import 'package:flutter/material.dart';
import 'package:phraser/util/colors.dart';


class NotificationTitleWidget extends StatelessWidget {
  const NotificationTitleWidget({Key? key ,required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineSmall?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTimeIcon(),
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTimeIcon() {
    switch (title.toLowerCase()) {
      case 'morning':
        return Icons.wb_sunny_outlined;
      case 'afternoon':
        return Icons.wb_sunny;
      case 'evening':
        return Icons.wb_twilight;
      case 'midnight':
        return Icons.bedtime_outlined;
      default:
        return Icons.schedule;
    }
  }
}
