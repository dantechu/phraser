import 'package:flutter/widgets.dart';

///An Extensiton on 'context' to support sizes based on percentage.
///usage: 'SizedBox(width:context.percentWidth * 10)' to size a widget to 10% of screen width
extension ContextSizeExtensions on BuildContext {
  /// To get a [MediaQuery] directly.
  MediaQueryData get mq => MediaQuery.of(this);

  /// Get MediaQuery Screen Size
  Size get screenSize => mq.size;

  /// Get MediaQuery Screen Density
  double get screenDensity => mq.devicePixelRatio;

  /// Get MediaQuery Screen Padding
  EdgeInsets get screenPadding => mq.padding;

  /// Get MediaQuery Screen Width
  double get screenWidth => mq.size.width;

  /// Get MediaQuery Screen Height
  double get screenHeight => mq.size.height;

  /// Get MediaQuery device pixel ratio
  double get devicePixelRatio => mq.devicePixelRatio;

  /// Get MediaQuery Screen Width in percentage
  double get percentWidth => screenWidth / 100;

  /// Get MediaQuery Screen height in percentage
  double get percentHeight => screenHeight / 100;
}
