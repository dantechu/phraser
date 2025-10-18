import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';

/// A beautiful, fully-fledged quote card widget with animations and visual effects
///
/// Features:
/// - Glassmorphism effect with blur
/// - Smooth fade-in animations
/// - Gradient overlays
/// - Elegant typography
/// - Responsive design
/// - Customizable appearance
class EnhancedQuoteCard extends StatefulWidget {
  final Phraser phraser;
  final Color? backgroundColor;
  final Color? textColor;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsets padding;
  final bool showCategory;
  final bool showGlassmorphism;
  final bool animate;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const EnhancedQuoteCard({
    Key? key,
    required this.phraser,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontFamily,
    this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.padding = const EdgeInsets.all(32.0),
    this.showCategory = true,
    this.showGlassmorphism = true,
    this.animate = true,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<EnhancedQuoteCard> createState() => _EnhancedQuoteCardState();
}

class _EnhancedQuoteCardState extends State<EnhancedQuoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuart),
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              minHeight: 200,
            ),
            decoration: widget.showGlassmorphism
                ? _buildGlassmorphismDecoration()
                : _buildSolidDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.showGlassmorphism ? 10 : 0,
                  sigmaY: widget.showGlassmorphism ? 10 : 0,
                ),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    gradient: widget.showGlassmorphism
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.05),
                            ],
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Decorative Quote Icon
                      _buildQuoteIcon(),

                      const SizedBox(height: 24),

                      // Quote Text
                      _buildQuoteText(),

                      if (widget.showCategory) ...[
                        const SizedBox(height: 24),
                        _buildCategoryBadge(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (widget.textColor ?? Colors.white).withOpacity(0.3),
            (widget.textColor ?? Colors.white).withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.format_quote,
        color: widget.textColor ?? Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildQuoteText() {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = widget.fontSize ?? _calculateFontSize(screenWidth);

    return Text(
      widget.phraser.quote,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: widget.textColor ?? Colors.white,
        fontSize: baseFontSize,
        fontWeight: widget.fontWeight,
        fontFamily: widget.fontFamily,
        height: 1.6,
        letterSpacing: 0.5,
        shadows: widget.showGlassmorphism
            ? [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.3),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: (widget.textColor ?? Colors.white).withOpacity(0.15),
        border: Border.all(
          color: (widget.textColor ?? Colors.white).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.phraser.categoryName.toUpperCase(),
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  BoxDecoration _buildGlassmorphismDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    );
  }

  BoxDecoration _buildSolidDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: widget.backgroundColor ?? Colors.black.withOpacity(0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  double _calculateFontSize(double screenWidth) {
    final quoteLength = widget.phraser.quote.length;

    if (quoteLength < 50) {
      return screenWidth * 0.08; // Large text for short quotes
    } else if (quoteLength < 100) {
      return screenWidth * 0.065; // Medium text
    } else if (quoteLength < 150) {
      return screenWidth * 0.055; // Smaller text
    } else {
      return screenWidth * 0.045; // Smallest text for long quotes
    }
  }
}

/// A minimalist quote card variant with clean design
class MinimalistQuoteCard extends StatelessWidget {
  final Phraser phraser;
  final Color? textColor;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;

  const MinimalistQuoteCard({
    Key? key,
    required this.phraser,
    this.textColor = Colors.white,
    this.fontFamily,
    this.fontSize,
    this.fontWeight = FontWeight.w300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = fontSize ?? screenWidth * 0.06;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Opening quote mark
            Text(
              '"',
              style: TextStyle(
                color: (textColor ?? Colors.white).withOpacity(0.5),
                fontSize: baseFontSize * 2,
                fontWeight: FontWeight.w200,
                height: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Quote text
            Text(
              phraser.quote,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: baseFontSize,
                fontWeight: fontWeight,
                fontFamily: fontFamily,
                height: 1.8,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Closing quote mark
            Text(
              '"',
              style: TextStyle(
                color: (textColor ?? Colors.white).withOpacity(0.5),
                fontSize: baseFontSize * 2,
                fontWeight: FontWeight.w200,
                height: 0.5,
              ),
            ),

            const SizedBox(height: 32),

            // Category indicator
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    (textColor ?? Colors.white).withOpacity(0.0),
                    (textColor ?? Colors.white).withOpacity(0.6),
                    (textColor ?? Colors.white).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card-style quote widget with elevated design
class ElevatedQuoteCard extends StatelessWidget {
  final Phraser phraser;
  final Color? cardColor;
  final Color? textColor;
  final String? fontFamily;
  final double? fontSize;
  final bool showAuthor;

  const ElevatedQuoteCard({
    Key? key,
    required this.phraser,
    this.cardColor,
    this.textColor,
    this.fontFamily,
    this.fontSize,
    this.showAuthor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor ?? (isDark ? Colors.grey[850] : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quote icon
            Icon(
              Icons.auto_stories_outlined,
              size: 40,
              color: (textColor ?? (isDark ? Colors.white : Colors.black87)).withOpacity(0.3),
            ),

            const SizedBox(height: 24),

            // Quote text
            Text(
              phraser.quote,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor ?? (isDark ? Colors.white : Colors.black87),
                fontSize: fontSize ?? 22,
                fontWeight: FontWeight.w400,
                fontFamily: fontFamily,
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 24),

            // Category
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (textColor ?? (isDark ? Colors.white : Colors.black87)).withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  phraser.categoryName,
                  style: TextStyle(
                    color: (textColor ?? (isDark ? Colors.white : Colors.black87)).withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (textColor ?? (isDark ? Colors.white : Colors.black87)).withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
