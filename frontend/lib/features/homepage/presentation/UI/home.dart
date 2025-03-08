import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the package to lock orientation
import 'package:tiny_talks/features/courses/presentation/UI/courses.dart';
import 'package:tiny_talks/features/profile/profile.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/quiz.dart';
import 'package:tiny_talks/features/rhymes/presentation/UI/rhymes.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock the orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      extendBodyBehindAppBar: true, // Extend body behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White for visibility
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/back.jpg', // Background image
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 220), // Space for the AppBar
              // Profile and Chest icons row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 135.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage()),
                          );
                      },
                      child: Image.asset(
                        'images/profile.png', // Replace with your profile image path
                        width: 90,
                        height: 90, 
                      ),
                    ),
                    const SizedBox(width: 16), 
                    // GestureDetector(
                    //   onTap: () {
                    //     // Add action for chest icon
                    //     print("Chest icon tapped");
                    //   },
                    //   child: Image.asset(
                    //     'images/chest.png',
                    //     width: 50,
                    //     height: 50,
                    //   ),
                    // ),
                  ],
                ),
              ),
              //const SizedBox(height: 2), 
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: <Widget>[
                    CategoryListTile(
                      title: 'Course',
                      icon: 'images/course.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Course()),
                        );
                      },
                      backgroundImage: 'images/h1.png',
                    ),
                    CategoryListTile(
                      title: 'Quiz',
                      icon: 'images/quiz.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizScreen()),
                        );
                      },
                      backgroundImage: 'images/h1.png',
                    ),
                    CategoryListTile(
                      title: 'Rhymes & Stories',
                      icon: 'images/rhymes.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RhymesPage()),
                        );
                      },
                      backgroundImage: 'images/h1.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryListTile extends StatelessWidget {
  final String title;
  final String icon; // Icon is now passed as a path
  final VoidCallback onTap;
  final String backgroundImage; // Background image for the tile

  const CategoryListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 80,
            ),
          ),
          // Icon and text overlay
          Row(
            children: [
              const SizedBox(width: 40), 
              Image.asset(
                icon,
                width: 60,
                height: 60,
              ),
              const Spacer(), // Push the text to the center
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(), // Add equal spacing after the text
            ],
          ),
        ],
      ),
    );
  }
}