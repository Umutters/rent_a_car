import 'package:flutter/material.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/gen/assets.gen.dart';
import 'package:rent_a_cart/pages/dashboarding_main_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.white, Color(0xFF1976D2)],
                center: Alignment.topRight,
                radius: 1.0,
                stops: [0.0, 1.0],
              ),
            ),
          ),
          Align(
            alignment: Alignment(
              1.0,
              -0.2 - (0.15 * (screenHeight / screenWidth).clamp(1, 2)),
            ),
            child: FractionalTranslation(
              translation: const Offset(0.45, 0.0),
              child: Image.asset(
                Assets.images.onboardingPage.path,
                width: screenWidth * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),
          PageView.builder(
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildPage(
                    context,
                    screenWidth,
                    screenHeight,
                    'Welcome to your\ngateway to exquisite\nluxury car rentals',
                    "We are thrilled to have you on board and can't wait\nto take you on a journey of unparalleled elegance\nand automotive excellence.",
                  );
                case 1:
                  return _buildPage(
                    context,
                    screenWidth,
                    screenHeight,
                    'Find Your Perfect\nLuxury Ride',
                    'Browse our exclusive collection of premium vehicles\nand choose the one that matches your style\nand preferences.',
                  );
                case 2:
                  return _buildPage(
                    context,
                    screenWidth,
                    screenHeight,
                    'Book with Ease\nand Confidence',
                    'Simple booking process with transparent pricing\nand flexible rental options to suit your needs.',
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
            itemCount: 3,
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            pageSnapping: true,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.45),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),
            // Page Indicator - sol tarafa hizalı
            Row(
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? AppColors.textPrimary
                            : const Color.fromARGB(102, 255, 255, 255),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.animateToPage(
                      _currentPage + 1,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const DashboardMainPage(),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.3,
                      vertical: 12.0,
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                ),
                child: Text(
                  _currentPage < 2 ? 'Next' : 'Get Started',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const DashboardMainPage(),
                    ),
                  );
                },
                child: Text(
                  "skip",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
