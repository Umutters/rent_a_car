import 'package:flutter/material.dart';
import 'package:rent_a_cart/gen/assets.gen.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Responsive alignment: üst ile orta arası, yüksekliğe göre ayarlanır
    final verticalAlign =
        -0.2 - (0.15 * (screenHeight / screenWidth).clamp(1, 2));
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Color(0xFF1976D2), // canlı mavi
                ],
                center: Alignment.topRight,
                radius: 1.0,
                stops: [0.0, 1.0],
              ),
            ),
          ),
          Align(
            alignment: Alignment(1.0, verticalAlign),
            child: FractionalTranslation(
              translation: const Offset(0.45, 0.0), // sağa kaydır
              child: Image.asset(
                Assets.images.onboardingPage.path,
                width: screenWidth * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: Alignment(1.0, verticalAlign),
            child: FractionalTranslation(
              translation: const Offset(0.45, 0.0), // sağa kaydır
              child: Image.asset(
                Assets.images.onboardingPage.path,
                width:
                    screenWidth *
                    0.8, // Ekrandan taşacak şekilde responsive genişlik
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.38,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 90.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to your\ngateway to exquisite\nluxury car rentals',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "We are thrilled to have you on board and can't wait\nto take you on a journey of unparalleled elegance\nand automotive excellence.",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},

                      style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.3,
                            vertical: 12.0,
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.white,
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "skip",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
