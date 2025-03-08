import 'dart:math';
import 'package:flutter/material.dart';

class MatchFollowingGame extends StatefulWidget {
  @override
  _MatchFollowingGameState createState() => _MatchFollowingGameState();
}

class _MatchFollowingGameState extends State<MatchFollowingGame> {
  final List<Map<String, String>> allPairs = [
    {'images': 'images/apple.png', 'nepali': 'स्याउ'},
    {'images': 'images/dog.png', 'nepali': 'कुकुर'},
    {'images': 'images/sun.png', 'nepali': 'सूर्य'},
    {'images': 'images/cat.png', 'nepali': 'बिरालो'},
    {'images': 'images/house.png', 'nepali': 'घर'},
    {'images': 'images/ball.png', 'nepali': 'बल'},
  ];

  late List<Map<String, String>> currentPairs;
  late List<Map<String, String>> shuffledPairs;
  List<Map<String, String>> matchedPairs = [];
  int coins = 0;
  bool showCongratulations = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    allPairs.shuffle(Random());
    currentPairs = allPairs.take(3).toList();
    shuffledPairs = List.from(currentPairs)..shuffle(Random());
    matchedPairs.clear();
    coins = 0;
    showCongratulations = false;
  }

  void _handleMatch(String nepaliWord) {
    setState(() {
      matchedPairs.add(currentPairs.firstWhere((pair) => pair['nepali'] == nepaliWord));
      coins += 10;
      if (matchedPairs.length == currentPairs.length) {
        showCongratulations = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.green.shade100,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/b1.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 141, 225, 96),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Match the picture with its Nepali name!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Expanded(
                child: showCongratulations
                    ? Center(
                        child: Container(
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Congratulations! 🎉',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'You earned $coins💰',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _initializeGame();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Play Again',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListView(
                              children: currentPairs
                                  .where((pair) => !matchedPairs.contains(pair))
                                  .map((pair) => Draggable<String>(
                                        data: pair['nepali']!,
                                        feedback: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            pair['images']!,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.5,
                                          child: Image.asset(
                                            pair['images']!,
                                            height: 140,
                                            width: 140,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(5),
                                          child: Image.asset(
                                            pair['images']!,
                                            height: 140,
                                            width: 140,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: shuffledPairs
                                  .where((pair) => !matchedPairs.contains(pair))
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
                                        onWillAccept: (data) => data == pair['nepali'],
                                        onAccept: (data) {
                                          _handleMatch(data);
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