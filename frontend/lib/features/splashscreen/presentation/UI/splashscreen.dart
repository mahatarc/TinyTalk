import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';
import 'package:flutter/services.dart';

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
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    
    // Lock device orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Preload images to prevent flickering
    Future.microtask(() {
      precacheImage(const AssetImage("images/Welcome2.png"), context);
      precacheImage(const AssetImage("images/play3.png"), context);
      precacheImage(const AssetImage("images/learn.png"), context);

            // Precache LoginPage assets
    precacheImage(AssetImage("images/logbg.png"), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> onBoardingPages = [
      OnboardingCard(
        image: "images/Welcome2.png",
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
      ),
      OnboardingCard(
        image: "images/play3.png",
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
      ),
      OnboardingCard(
        image: "images/learn.png",
        buttonText: 'Done',
        onPressed: () {
          if (!_isNavigating) {
            setState(() {
              _isNavigating = true;
            });
            Navigator.of(context).pushReplacement(_fadeRoute(const LoginPage()));
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Prevents white flicker
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: onBoardingPages,
          ),
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: onBoardingPages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: oliveGreen,
                dotColor: oliveGreenLight,
              ),
              onDotClicked: (index) {
                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// **Custom Fade Page Route**
PageRouteBuilder _fadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    opaque: false,  // Set opaque to false to ensure smooth background transition
    barrierColor: Colors.black.withOpacity(0), // Transparent barrier color
    //opaque: true, // Ensures a smooth transition without flickering
    //barrierColor: Colors.black, // Keeps the background black to avoid flickering
  );
}

// **OnboardingCard**
class OnboardingCard extends StatelessWidget {
  final String image, buttonText;
  final VoidCallback onPressed;

  const OnboardingCard({
    super.key,
    required this.image,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.3)), // Dark overlay
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MaterialButton(
              minWidth: 200,
              onPressed: onPressed,
              color: oliveGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ],
    );
  }
}