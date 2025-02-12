import 'package:flutter/material.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/correctanswer.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/matchfollowing.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/matchhalf.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
      appBar: AppBar(
     //   title: Text('Quiz Games', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
     //   elevation: 1,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/bg11.jpg', 
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centering the content vertically
                children: [
                  CategoryListTile(
                    title: 'Match the Letters',
                    icon: 'images/cube.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchHalfGame(),
                        ),
                      );
                    },
                    backgroundImage: 'images/h1.png', 
                  ),
                  const SizedBox(height: 2), 
                  CategoryListTile(
                    title: 'Match the Following',
                    icon: 'images/match.png', 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchFollowingGame(),
                        ),
                      );
                    },
                    backgroundImage: 'images/h1.png',
                  ),
                  const SizedBox(height: 2), 
                  CategoryListTile(
                    title: 'Identify from Picture',
                    icon: 'images/puzzle.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CorrectAnswer(),
                        ),
                      );
                    },
                    backgroundImage: 'images/h1.png',
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
              height: 100, // Increased height for the tile
            ),
          ),
          // Icon and text overlay
          Row(
            children: [
              const SizedBox(width: 35), // Padding from the left
              Image.asset(
                icon,
                width: 70, // Increased icon size
                height: 70, // Increased icon size
              ),
             const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22, // Increased text size
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 229, 235, 200), // White color for contrast
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
