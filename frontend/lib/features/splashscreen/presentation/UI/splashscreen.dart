import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';

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
        title: 'Welcome to Tiny Talks!',
        description:
            'Your Nepali Learning Adventure Begins Here!',
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "images/onboarding.png",
        title: 'Learn and Play with Joy',
        description:
            'Let’s Talk Nepali and Have Fun!',
        buttonText: 'Next',
        onPressed: () {
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        },
      ),
      OnboardingCard(
        image: "images/cube.png",
        title: 'Learn Personally',
        description:
            'Your Nepali Learning Adventure Begins Here!',
        buttonText: 'Done',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: onBoardingPages,
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: onBoardingPages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Theme.of(context).colorScheme.secondary,
              ),
              onDotClicked: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lobster(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 199, 158, 158),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700], 
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Times New Roman', // Custom font family for the description
                  ),
                ),
              )
            ],
          ),
          MaterialButton(
            minWidth: 300,
            onPressed: () => onPressed(),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
