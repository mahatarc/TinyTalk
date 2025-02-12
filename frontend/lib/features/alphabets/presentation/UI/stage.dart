import 'package:flutter/material.dart';
import 'alphabet.dart';

class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});

  @override
  _StagesScreenState createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen> {
  List<bool> stageCompletionStatus = [true, false, false, false, false]; // Initially, only Stage 1 is unlocked

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/stage.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stageCompletionStatus.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: stageCompletionStatus[index]
                      ? () => _navigateToAlphabetPages(index)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          stageCompletionStatus[index]
                              ? 'images/stage${index + 1}.png'
                              : 'images/locked.png',
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to AlphabetPage for the specific stage
  void _navigateToAlphabetPages(int stageIndex) {
    final startLetterIndex = stageIndex * 5; // Starting index for the current stage's alphabets
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlphabetPage(
          startLetterIndex: startLetterIndex,
          onFinish: () => _unlockNextStage(stageIndex),
        ),
      ),
    );
  }

  // Unlock the next stage after completion of the current stage
  void _unlockNextStage(int currentStageIndex) {
    setState(() {
      if (currentStageIndex + 1 < stageCompletionStatus.length) {
        stageCompletionStatus[currentStageIndex + 1] = true;
      }
    });
  }
}
