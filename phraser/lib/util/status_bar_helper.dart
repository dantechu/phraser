import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';

class StatusBarHelper {
  static Widget standardSafeArea({
    required BuildContext context,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ColorfulSafeArea(
      color: isDark ? Colors.grey[900]! : Colors.grey[50]!,
      child: child,
    );
  }
  
  static Color getStatusBarColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[900]! : Colors.grey[50]!;
  }
}