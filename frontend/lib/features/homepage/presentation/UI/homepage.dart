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
                IconButton(
                  icon: Image.asset(
                    'images/profile.png',
                    width: 65, 
                    height: 65,
                  ),
                  onPressed: () {
                    Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfilePage(

                              )),
                            );
                  },
                ),
                // const SizedBox(height: 1), 
                // IconButton(
                //   icon: Image.asset(
                //     'images/chest.png',
                //     width: 50, 
                //     height: 50,
                //   ),
                //   onPressed: () {
                //     print("Chest button tapped");
                //   },
                // ),
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
                  width: 430, 
                  height: 430,
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