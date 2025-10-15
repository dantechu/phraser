import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/consts/colors.dart';
import 'package:phraser/screens/notification_settings/free_notifications_settings.dart';

class ImprovedInterestScreen extends StatefulWidget {
  const ImprovedInterestScreen({Key? key}) : super(key: key);

  @override
  ImprovedInterestScreenState createState() => ImprovedInterestScreenState();
}

class ImprovedInterestScreenState extends State<ImprovedInterestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<InterestItem> interests = [];
  int selectedCount = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initInterests();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  void _initInterests() {
    interests = [
      InterestItem(
        name: 'Achieving Goals',
        icon: Icons.flag_outlined,
        color: Colors.blue,
        description: 'Stay focused and reach your targets',
      ),
      InterestItem(
        name: 'Positive Mindset',
        icon: Icons.psychology_outlined,
        color: Colors.purple,
        description: 'Build optimism and resilience',
      ),
      InterestItem(
        name: 'Self-Esteem',
        icon: Icons.favorite_outline,
        color: Colors.pink,
        description: 'Boost confidence and self-worth',
      ),
      InterestItem(
        name: 'Stress & Anxiety',
        icon: Icons.spa_outlined,
        color: Colors.teal,
        description: 'Find calm and inner peace',
      ),
      InterestItem(
        name: 'Relationships',
        icon: Icons.people_outline,
        color: Colors.orange,
        description: 'Improve connections with others',
      ),
      InterestItem(
        name: 'Happiness',
        icon: Icons.wb_sunny_outlined,
        color: Colors.amber,
        description: 'Cultivate joy and gratitude',
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleInterest(int index) {
    setState(() {
      interests[index].isSelected = !interests[index].isSelected;
      selectedCount = interests.where((i) => i.isSelected).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.kPrayerIcon,
                          width: 60,
                          height: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'What would you like to improve?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Select areas that matter most to you',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Selection counter
                      if (selectedCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '$selectedCount ${selectedCount == 1 ? 'area' : 'areas'} selected',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Interest cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: List.generate(
                        interests.length,
                        (index) => _buildInterestCard(
                          interests[index],
                          index,
                          isDark,
                        ),
                      ),
                    ),
                  ),
                ),

                // Continue button
                _buildContinueButton(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestCard(InterestItem interest, int index, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleInterest(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: interest.isSelected
                  ? interest.color.withOpacity(0.15)
                  : (isDark ? Colors.grey[850] : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: interest.isSelected
                    ? interest.color
                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                width: interest.isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (interest.isSelected)
                  BoxShadow(
                    color: interest.color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: interest.isSelected
                        ? interest.color
                        : interest.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    interest.icon,
                    color: interest.isSelected
                        ? Colors.white
                        : interest.color,
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
                        interest.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: interest.isSelected
                              ? interest.color
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        interest.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: interest.isSelected
                        ? interest.color
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: interest.isSelected
                          ? interest.color
                          : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                      width: 2,
                    ),
                  ),
                  child: interest.isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: selectedCount > 0
              ? () {
                  const FreeNotificationSettingsScreen(willPop: false)
                      .launch(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
            foregroundColor: Colors.white,
            elevation: selectedCount > 0 ? 8 : 0,
            shadowColor: AppColors.primaryColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedCount > 0
                    ? 'Continue with $selectedCount ${selectedCount == 1 ? 'area' : 'areas'}'
                    : 'Select at least one area',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selectedCount > 0
                      ? Colors.white
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
              if (selectedCount > 0) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class InterestItem {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  bool isSelected;

  InterestItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    this.isSelected = false,
  });
}
