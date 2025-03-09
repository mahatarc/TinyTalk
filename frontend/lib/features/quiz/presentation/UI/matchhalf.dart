import 'dart:math';
import 'package:flutter/material.dart';

class MatchHalfGame extends StatefulWidget {
  @override
  _MatchHalfGameState createState() => _MatchHalfGameState();
}

class _MatchHalfGameState extends State<MatchHalfGame> {
  final List<Map<String, String>> nepaliPairs = [
    {'half1': 'рдХ', 'half2': 'рдХ'},
    {'half1': 'рдЦ', 'half2': 'рдЦ'},
    {'half1': 'рдЧ', 'half2': 'рдЧ'},
    {'half1': 'рдШ', 'half2': 'рдШ'},
    {'half1': 'рдЩ', 'half2': 'рдЩ'},
    {'half1': 'рдЪ', 'half2': 'рдЪ'},
    {'half1': 'рдЫ', 'half2': 'рдЫ'},
    {'half1': 'рдЬ', 'half2': 'рдЬ'},
    {'half1': 'рдЭ', 'half2': 'рдЭ'},
    {'half1': 'рдЮ', 'half2': 'рдЮ'},
    {'half1': 'рдЯ', 'half2': 'рдЯ'},
    {'half1': 'рда', 'half2': 'рда'},
    {'half1': 'рдб', 'half2': 'рдб'},
    {'half1': 'рдв', 'half2': 'рдв'},
    {'half1': 'рдг', 'half2': 'рдг'},
    {'half1': 'рдд', 'half2': 'рдд'},
    {'half1': 'рде', 'half2': 'рде'},
    {'half1': 'рдж', 'half2': 'рдж'},
    {'half1': 'рдз', 'half2': 'рдз'},
    {'half1': 'рди', 'half2': 'рди'},
    {'half1': 'рдк', 'half2': 'рдк'},
    {'half1': 'рдл', 'half2': 'рдл'},
    {'half1': 'рдм', 'half2': 'рдм'},
    {'half1': 'рдн', 'half2': 'рдн'},
    {'half1': 'рдо', 'half2': 'рдо'},
    {'half1': 'рдп', 'half2': 'рдп'},
    {'half1': 'рд░', 'half2': 'рд░'},
    {'half1': 'рд▓', 'half2': 'рд▓'},
    {'half1': 'рд╡', 'half2': 'рд╡'},
    {'half1': 'рд╢', 'half2': 'рд╢'},
    {'half1': 'рд╖', 'half2': 'рд╖'},
    {'half1': 'рд╕', 'half2': 'рд╕'},
    {'half1': 'рд╣', 'half2': 'рд╣'},
    {'half1': 'рдХреНрд╖', 'half2': 'рдХреНрд╖'},
    {'half1': 'рддреНрд░', 'half2': 'рддреНрд░'},
    {'half1': 'рдЬреНрдЮ', 'half2': 'рдЬреНрдЮ'},
  ];

  List<Map<String, String>> currentPairs = [];
  List<Map<String, String>> shuffledPairs = [];
  List<Map<String, String>> matchedPairs = [];
  int coins = 0;
  bool isGameCompleted = false;

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
    matchedPairs.clear();
    isGameCompleted = false;
  }

  void _checkGameCompletion() {
    if (matchedPairs.length == currentPairs.length) {
      setState(() {
        coins += 30;
        isGameCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent
      ),
        extendBodyBehindAppBar: true,

      body: Stack(
        
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/backg.jpg',
              fit: BoxFit.cover,
            ),
          ),
        
          Center(
            child: Column(
          
              children: [
SizedBox(height: 80),

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
                if (isGameCompleted)
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Congratulations! You got 30 coins! ЁЯОЙ',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
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
                                          fontSize: 30,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Text(
                                      pair['half1']!,
                                      style: TextStyle(
                                          fontSize: 40, color: Colors.grey),
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
                                        margin: const EdgeInsets.symmetric(vertical: 20),
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
                                      _checkGameCompletion();
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