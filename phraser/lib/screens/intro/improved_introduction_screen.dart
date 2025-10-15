import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phraser/consts/assets.dart';
import 'package:phraser/consts/colors.dart';
import 'package:phraser/consts/const_strings.dart';
import 'package:phraser/screens/intro/interest_life_areas_screen.dart';
import '../../util/colors.dart';

class ImprovedIntroductionScreen extends StatefulWidget {
  @override
  ImprovedIntroductionScreenState createState() => ImprovedIntroductionScreenState();
}

class ImprovedIntroductionScreenState extends State<ImprovedIntroductionScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();
  int currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<OnboardingPage> pages = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initPages();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  void _initPages() {
    pages = [
      OnboardingPage(
        title: '✨ Transform Your Mindset',
        subtitle: 'Read powerful ${ConstStrings.kAppNamePlural} every day to build a positive and resilient mindset.',
        image: AppAssets.kIntroOne,
        gradient: [kPrimaryColor.withOpacity(0.8), kPrimaryColor],
        icon: Icons.psychology_outlined,
      ),
      OnboardingPage(
        title: '💪 Break Free from Negativity',
        subtitle: 'Turn your negative thoughts into positive affirmations and unlock your true potential.',
        image: AppAssets.kIntroTwo,
        gradient: [Colors.purple.shade400, Colors.deepPurple.shade600],
        icon: Icons.favorite_outline,
      ),
      OnboardingPage(
        title: '🌟 Your Best Days Start Here',
        subtitle: 'Boost your self-confidence and feel positive about yourself with daily inspiration.',
        image: AppAssets.kIntroThree,
        gradient: [Colors.orange.shade400, Colors.deepOrange.shade600],
        icon: Icons.wb_sunny_outlined,
      ),
    ];
  }

  @override
  void dispose() {
    pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
    // Restart animations for new page
    _fadeController.reset();
    _scaleController.reset();
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: currentPage < pages.length
                    ? pages[currentPage].gradient
                    : [kPrimaryColor, kPrimaryColor],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (currentPage != 2)
                        TextButton(
                          onPressed: () {
                            InterestLifeAreasScreen().launch(context);
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // PageView with animated content
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(pages[index], index);
                    },
                  ),
                ),

                // Page indicators
                _buildPageIndicators(),

                // Navigation button
                _buildNavigationButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon at top
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Image with hero effect
              Hero(
                tag: 'intro_image_$index',
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      page.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title with animation
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                page.subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pages.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: currentPage == index ? 24 : 8,
            decoration: BoxDecoration(
              color: currentPage == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (currentPage == pages.length - 1) {
              InterestLifeAreasScreen().launch(context);
            } else {
              pageController.animateToPage(
                currentPage + 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: pages[currentPage].gradient.last,
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentPage == pages.length - 1 ? 'Get Started' : 'Continue',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                currentPage == pages.length - 1
                    ? Icons.arrow_forward
                    : Icons.arrow_forward_ios,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String image;
  final List<Color> gradient;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.gradient,
    required this.icon,
  });
}
