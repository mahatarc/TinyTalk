import 'package:flutter/material.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/correctanswer.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/matchfollowing.dart';
import 'package:tiny_talks/features/quiz/presentation/UI/matchhalf.dart';

class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        
        title: Text(
          'Quiz Games',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bubblegum Sans', // Stylish font
          ),
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 128, 191, 125),
      ),
      body: Stack(
        children: [
          // Main background image
          Positioned.fill(
            child: Image.asset(
              'images/bg.jpg', // Replace with your background asset path
              fit: BoxFit.cover,
            ),
          ),
          // Wooden board background image
          Positioned.fill(
            child: Image.asset(
              'images/b2.png', // Replace with your wooden board asset path
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width * 0.8, // Adjust width
            ),
          ),
          // Centered content over the wooden board
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildQuizOption(
                  context,
                  'Match Letters',
                  'images/cube.png',
                  MatchHalfGame(),
                ),
                SizedBox(height: 50), // Adjust spacing
                buildQuizOption(
                  context,
                  'Match Following',
                  'images/match.png',
                  MatchFollowingGame(),
                ),
                SizedBox(height: 100), // Adjust spacing
                buildQuizOption(
                  context,
                  'Identify from Picture',
                  'images/puzzle.png',
                  CorrectAnswer(),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuizOption(BuildContext context, String title, String imagePath, Widget nextScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon at the top
          Image.asset(
            imagePath,
            height: 90,
            width: 90,
          ),
          SizedBox(height: 0), // Space between icon and text
          // Text below the icon
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Bubblegum Sans', // Stylish font
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}