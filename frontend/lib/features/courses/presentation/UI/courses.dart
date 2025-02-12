import 'package:flutter/material.dart';
import 'package:tiny_talks/features/alphabets/presentation/UI/Sworbarna.dart';
import 'package:tiny_talks/features/alphabets/presentation/UI/stage.dart';
import 'package:tiny_talks/features/numbers/presentation/UI/numbers.dart';

class Course extends StatelessWidget {
  const Course({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend body behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        title: const Text('Course'),
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
              'images/bg88.jpg', // Background image
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
                      title: 'स्वर वर्ण',
                      icon: 'images/swor.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Sworbarna()),
                        );
                      },
                      backgroundImage: 'images/h1.png',
                    ),
                    CategoryListTile(
                      title: 'व्यंजन वर्ण',
                      icon: 'images/byanjan.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  StagesScreen()),
                        );
                      },
                      backgroundImage: 'images/h1.png',
                    ),
                    CategoryListTile(
                      title: 'अंक',
                      icon: 'images/numbers.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  Numbers()),
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
  final String icon; // Icon path as a string
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
                width: 60,
                height: 60,
              ),
              const Spacer(), // Push the text to the center
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
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
