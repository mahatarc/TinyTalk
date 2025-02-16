import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';

// Olive Green Color Constants
const Color oliveGreen = Color.fromARGB(255, 67, 129, 78);
const Color oliveGreenLight = Color.fromARGB(255, 131, 127, 78);

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final List<Widget> onBoardingPages = [
      OnboardingCard(
        image: "images/welcome.png",
        title: '',
        description: '',
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.linear);
        },
      ),
      OnboardingCard(
        image: "images/splash1.png",
        title: '',
        description: '',
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.linear);
        },
      ),
      OnboardingCard(
        image: "images/splash2.png",
        title: '',
        description: '',
        buttonText: 'Done',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(controller: _pageController, children: onBoardingPages),
          Positioned(
            bottom: 30,
            left: MediaQuery.sizeOf(context).width / 2 - 50,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: onBoardingPages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: oliveGreen,
                dotColor: oliveGreenLight,
              ),
              onDotClicked: (index) {
                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.linear);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Updated OnboardingCard with Olive Green Button
class OnboardingCard extends StatelessWidget {
  final String image, title, description, buttonText;
  final Function onPressed;

  const OnboardingCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLandscape = constraints.maxWidth > constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Full-screen background image
            Image.asset(image, fit: BoxFit.cover),

            // Dark overlay for readability
            Container(color: Colors.black.withOpacity(0.3)),

            // Responsive content layout
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lobster(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: isLandscape ? 48 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isLandscape ? 100.0 : 20.0),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isLandscape ? 24 : 18,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                MaterialButton(
                  minWidth: isLandscape ? 300 : 200,
                  onPressed: () => onPressed(),
                  color: oliveGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLandscape ? 24 : 20,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ],
        );
      },
    );
  }
}