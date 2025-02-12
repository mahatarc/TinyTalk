import 'dart:math';
import 'package:flutter/material.dart';

class MatchHalfGame extends StatefulWidget {
  @override
  _MatchHalfGameState createState() => _MatchHalfGameState();
}

class _MatchHalfGameState extends State<MatchHalfGame> {
  final List<Map<String, String>> nepaliPairs = [
    {'half1': 'क', 'half2': 'क'},
    {'half1': 'ख', 'half2': 'ख'},
    {'half1': 'ग', 'half2': 'ग'},
    {'half1': 'घ', 'half2': 'घ'},
    {'half1': 'ङ', 'half2': 'ङ'},
    {'half1': 'च', 'half2': 'च'},
    {'half1': 'छ', 'half2': 'छ'},
    {'half1': 'ज', 'half2': 'ज'},
    {'half1': 'झ', 'half2': 'झ'},
    {'half1': 'ञ', 'half2': 'ञ'},
    {'half1': 'ट', 'half2': 'ट'},
    {'half1': 'ठ', 'half2': 'ठ'},
    {'half1': 'ड', 'half2': 'ड'},
    {'half1': 'ढ', 'half2': 'ढ'},
    {'half1': 'ण', 'half2': 'ण'},
    {'half1': 'त', 'half2': 'त'},
    {'half1': 'थ', 'half2': 'थ'},
    {'half1': 'द', 'half2': 'द'},
    {'half1': 'ध', 'half2': 'ध'},
    {'half1': 'न', 'half2': 'न'},
    {'half1': 'प', 'half2': 'प'},
    {'half1': 'फ', 'half2': 'फ'},
    {'half1': 'ब', 'half2': 'ब'},
    {'half1': 'भ', 'half2': 'भ'},
    {'half1': 'म', 'half2': 'म'},
    {'half1': 'य', 'half2': 'य'},
    {'half1': 'र', 'half2': 'र'},
    {'half1': 'ल', 'half2': 'ल'},
    {'half1': 'व', 'half2': 'व'},
    {'half1': 'श', 'half2': 'श'},
    {'half1': 'ष', 'half2': 'ष'},
    {'half1': 'स', 'half2': 'स'},
    {'half1': 'ह', 'half2': 'ह'},
    {'half1': 'क्ष', 'half2': 'क्ष'},
    {'half1': 'त्र', 'half2': 'त्र'},
    {'half1': 'ज्ञ', 'half2': 'ज्ञ'},
  ];

  List<Map<String, String>> currentPairs = [];
  List<Map<String, String>> shuffledPairs = [];
  List<Map<String, String>> matchedPairs = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    List<Map<String, String>> shuffledNepaliPairs = List.from(nepaliPairs);
    shuffledNepaliPairs.shuffle(Random());
    currentPairs = shuffledNepaliPairs.take(3).toList();
    shuffledPairs = List.from(currentPairs);
    shuffledPairs.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Nepali Letters'),
        backgroundColor: const Color.fromARGB(255, 118, 181, 111),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/bg.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 149, 212, 106),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Match the Letters!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: currentPairs
                            .map((pair) => Draggable<String>(
                                  data: pair['half1']!,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      pair['half1']!,
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Text(
                                    pair['half1']!,
                                    style:
                                        TextStyle(fontSize: 40, color: Colors.grey),
                                  ),
                                  child: Text(
                                    pair['half1']!,
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ))
                            .toList(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: shuffledPairs
                            .map((pair) => DragTarget<String>(
                                  builder: (context, candidateData, rejectedData) {
                                    bool isMatched = matchedPairs.any((matched) =>
                                        matched['half2'] == pair['half2']);
                                    return Container(
                                      margin:
                                          const EdgeInsets.symmetric(vertical: 20),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isMatched
                                            ? Colors.green.shade300
                                            : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        pair['half2']!,
                                        style: TextStyle(
                                          fontSize: 40,
                                          color: isMatched
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                  onWillAccept: (data) {
                                    return data == pair['half1'];
                                  },
                                  onAccept: (data) {
                                    setState(() {
                                      matchedPairs.add({
                                        'half1': data,
                                        'half2': pair['half2']!,
                                      });
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Matched $data with ${pair['half2']}!'),
                                        backgroundColor: Colors.blue,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            matchedPairs.clear();
            _initializeGame();
          });
        },
        child: const Icon(Icons.refresh),
        backgroundColor: const Color.fromARGB(255, 80, 202, 114),
      ),
    );
  }
}

