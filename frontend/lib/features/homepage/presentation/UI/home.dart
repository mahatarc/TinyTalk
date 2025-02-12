import 'package:flutter/material.dart';
import 'package:tiny_talks/features/courses/presentation/UI/courses.dart';
import 'package:tiny_talks/features/profile/presentation/UI/profile.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/quiz.dart';
import 'package:tiny_talks/features/rhymes/presentation/UI/rhymes.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend body behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 18, 16, 16)), // White for visibility
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Profile picture at the top right
          GestureDetector(
            onTap: () {
              // Navigate to the profile screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: CircleAvatar(
                radius: 40, // Size of the profile picture
                backgroundImage: AssetImage('images/pp.png'), // Replace with your profile image
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/stage.jpg', // Background image
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Column(
            children: <Widget>[
              const SizedBox(height: 290), // Spacer for content positioning
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
                      title: 'Rhymes',
                      icon: 'images/rhymes.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  RhymesPage()),
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
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 80, // Adjust height for the tile
            ),
          ),
          // Icon and text overlay
          Row(
            children: [
              const SizedBox(width: 40), // Padding from the left
              Image.asset(
                icon,
                width: 70,
                height: 70,
              ),
              const Spacer(), // Push the text to the center
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White color for contrast
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
