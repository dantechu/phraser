import 'package:flutter/material.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'enhanced_quote_card.dart';

/// Enum for different quote display styles
enum QuoteDisplayStyle {
  glassmorphism,
  minimalist,
  elevated,
  original,
}

/// Factory class for creating different quote display widgets
class QuoteDisplayFactory {
  /// Creates a quote widget based on the selected style
  static Widget createQuoteWidget({
    required QuoteDisplayStyle style,
    required Phraser phraser,
    Color? textColor,
    Color? backgroundColor,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    bool animate = true,
    VoidCallback? onTap,
  }) {
    switch (style) {
      case QuoteDisplayStyle.glassmorphism:
        return EnhancedQuoteCard(
          phraser: phraser,
          textColor: textColor,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          showGlassmorphism: true,
          animate: animate,
          onTap: onTap,
        );

      case QuoteDisplayStyle.minimalist:
        return MinimalistQuoteCard(
          phraser: phraser,
          textColor: textColor,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );

      case QuoteDisplayStyle.elevated:
        return ElevatedQuoteCard(
          phraser: phraser,
          cardColor: backgroundColor,
          textColor: textColor,
          fontFamily: fontFamily,
          fontSize: fontSize,
        );

      case QuoteDisplayStyle.original:
        // Return a simple centered text for backward compatibility
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
            child: Text(
              phraser.quote,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 24,
                fontWeight: fontWeight ?? FontWeight.w400,
                fontFamily: fontFamily,
                height: 1.6,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  /// Get style name for display
  static String getStyleName(QuoteDisplayStyle style) {
    switch (style) {
      case QuoteDisplayStyle.glassmorphism:
        return 'Glassmorphism';
      case QuoteDisplayStyle.minimalist:
        return 'Minimalist';
      case QuoteDisplayStyle.elevated:
        return 'Elevated Card';
      case QuoteDisplayStyle.original:
        return 'Original';
    }
  }

  /// Get style description
  static String getStyleDescription(QuoteDisplayStyle style) {
    switch (style) {
      case QuoteDisplayStyle.glassmorphism:
        return 'Modern frosted glass effect with blur';
      case QuoteDisplayStyle.minimalist:
        return 'Clean and simple design';
      case QuoteDisplayStyle.elevated:
        return 'Card-based design with shadow';
      case QuoteDisplayStyle.original:
        return 'Classic text display';
    }
  }

  /// Get style icon
  static IconData getStyleIcon(QuoteDisplayStyle style) {
    switch (style) {
      case QuoteDisplayStyle.glassmorphism:
        return Icons.blur_on;
      case QuoteDisplayStyle.minimalist:
        return Icons.text_fields;
      case QuoteDisplayStyle.elevated:
        return Icons.layers;
      case QuoteDisplayStyle.original:
        return Icons.format_quote;
    }
  }
}

/// Widget for selecting quote display style
class QuoteStyleSelector extends StatelessWidget {
  final QuoteDisplayStyle currentStyle;
  final Function(QuoteDisplayStyle) onStyleChanged;

  const QuoteStyleSelector({
    Key? key,
    required this.currentStyle,
    required this.onStyleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quote Display Style',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Style options
          ...QuoteDisplayStyle.values.map((style) {
            final isSelected = style == currentStyle;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  onStyleChanged(style);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? Colors.blue[800] : Colors.blue[50])
                        : (isDark ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : (isDark ? Colors.grey[700] : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          QuoteDisplayFactory.getStyleIcon(style),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              QuoteDisplayFactory.getStyleName(style),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              QuoteDisplayFactory.getStyleDescription(style),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Check icon
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
