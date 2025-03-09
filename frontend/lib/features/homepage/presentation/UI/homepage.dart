import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiny_talks/features/homepage/presentation/UI/home.dart';
import 'package:tiny_talks/features/profile/presentation/UI/profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/main.png',
              fit: BoxFit.cover,
            ),
          ),
          // Top-right icons
          Positioned(
            top: 35, 
            right: 5, 
            child: Column(
              children: [
                // Clickable profile image with InkWell and effect
                InkWell(
                  borderRadius: BorderRadius.circular(65), // Circular border for InkWell
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  onHover: (isHovered) {
                    // Optional hover effect (if needed for web)
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 65,  // Size of the image
                    height: 65, // Size of the image
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Makes it circular
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(183, 16, 0, 0).withOpacity(0.6),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'images/profile.png',
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover, // Ensures the image fills the circle properly
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Play button
          Positioned(
            bottom: 200, 
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                child: Image.asset(
                  'images/play.png',
                  width: 350, 
                  height: 350,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MaterialApp(
      home: HomeScreen(),
    ));
  });
}
