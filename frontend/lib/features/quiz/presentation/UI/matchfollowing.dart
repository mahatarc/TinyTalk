import 'dart:math';
import 'package:flutter/material.dart';

class MatchFollowingGame extends StatefulWidget {
  const MatchFollowingGame({super.key});

  @override
  _MatchFollowingGameState createState() => _MatchFollowingGameState();
}

class _MatchFollowingGameState extends State<MatchFollowingGame> {
  // Define the full set of pairs
  final List<Map<String, String>> allPairs = [
    {'images': 'images/apple.png', 'nepali': 'स्याउ'},
    {'images': 'images/dog.png', 'nepali': 'कुकुर'},
    {'images': 'images/sun.png', 'nepali': 'सूर्य'},
    {'images': 'images/cat.png', 'nepali': 'बिरालो'},
    {'images': 'images/house.png', 'nepali': 'घर'},
    {'images': 'images/ball.png', 'nepali': 'बल'},
    // Add more pairs as needed
  ];

  late List<Map<String, String>> currentPairs;
  late List<Map<String, String>> shuffledPairs;

  @override
  void initState() {
    super.initState();
    _initializeGame(); // Automatically select 3 random pairs when the screen loads
  }

  void _initializeGame() {
    // Shuffle all pairs and select the first 3
    allPairs.shuffle(Random());
    currentPairs = allPairs.take(3).toList(); // Take only 3 pairs for the current game

    // Shuffle the selected pairs for RHS display
    shuffledPairs = List.from(currentPairs);
    shuffledPairs.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/b1.jpg'), // Background image for the screen
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Instruction with background image for the text
              const SizedBox(height: 100),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/h1.png'), // Background image for the text
                    fit: BoxFit.cover,  // Make the background image cover the entire area
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'जोड़ा मिलाउ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              // Game Area
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pictures column (Draggable)
                    Expanded(
                      child: ListView(
                        children: currentPairs
                            .map((pair) => Draggable<String>(
                                  data: pair['nepali']!,
                                  feedback: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      pair['images']!,
                                      height: 160, // Increased image size
                                      width: 160,  // Increased image size
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: Image.asset(
                                      pair['images']!,
                                      height: 160, // Increased image size
                                      width: 160,  // Increased image size
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    child: Image.asset(
                                      pair['images']!,
                                      height: 160, // Increased image size
                                      width: 160,  // Increased image size
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    // Nepali names column (DragTarget)
                    Expanded(
                      child: ListView(
                        children: shuffledPairs
                            .map((pair) => DragTarget<String>(
                                  builder: (context, candidateData, rejectedData) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 35),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: candidateData.isEmpty
                                            ? Colors.white
                                            : const Color.fromARGB(255, 174, 230, 110),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.deepPurple,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        pair['nepali']!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    );
                                  },
                                  onWillAcceptWithDetails: (data) => data == pair['nepali'],
                                  onAcceptWithDetails: (data) {
                                    // Correct Match
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Correct! Matched ${pair['nepali']}',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
