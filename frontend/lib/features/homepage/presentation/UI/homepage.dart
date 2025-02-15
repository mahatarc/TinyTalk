import 'package:flutter/material.dart';
import 'package:tiny_talks/features/homepage/presentation/UI/home.dart';
import 'package:tiny_talks/features/profile/profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            top: 20, // Adjust the vertical padding
            right: 5, // Adjust the horizontal padding
            child: Column(
              children: [
                IconButton(
                  icon: Image.asset('images/profile.png',
                    width: 50, 
                    height: 50,
                  ),
                  onPressed: () {
                    // Navigate to Profile Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage(name: '', email: '')),
                    );
                  },
                ),
                const SizedBox(height: 1), // Spacing between icons
                IconButton(
                  icon: Image.asset('images/chest.png',
                    width: 50, 
                    height: 50,
                  ),
                  onPressed: () {
                    print("Chest button tapped");
                  },
                ),
              ],
            ),
          ),
          
          // Play button
          Positioned(
            bottom: 200, // Adjust the vertical position of the play button
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
                  width: 430, // Adjust the size of the play button
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
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}