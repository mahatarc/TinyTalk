import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Preload images to prevent flickering
    Future.delayed(Duration.zero, () {
      precacheImage(AssetImage("images/Welcome2.png"), context);
      precacheImage(AssetImage("images/play3.png"), context);
      precacheImage(AssetImage("images/learn.png"), context);
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
            // Adding delay to prevent flicker
            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.of(context).pushReplacement(_transparentRoute(const LoginPage()));
            });
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Eliminates default white flicker
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: onBoardingPages,
          ),
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
                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// **Custom Transparent Page Route**
PageRouteBuilder _transparentRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    opaque: false, // Prevents white screen flash
    barrierColor: Colors.transparent, // Keeps the background from turning white
  );
}

// **OnboardingCard**
class OnboardingCard extends StatefulWidget {
  final String image, buttonText;
  final Function onPressed;

  const OnboardingCard({
    super.key,
    required this.image,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  _OnboardingCardState createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<OnboardingCard> {
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load image and fade it in
    Future.delayed(Duration.zero, () {
      precacheImage(AssetImage(widget.image), context).then((_) {
        if (mounted) {
          setState(() {
            _isImageLoaded = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          opacity: _isImageLoaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Image.asset(widget.image, fit: BoxFit.cover),
        ),
        Container(color: Colors.black.withOpacity(0.3)),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MaterialButton(
              minWidth: 200,
              onPressed: () => widget.onPressed(),
              color: oliveGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Text(
                widget.buttonText,
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
