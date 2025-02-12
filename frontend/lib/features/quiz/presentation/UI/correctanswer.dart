import 'package:flutter/material.dart';

class CorrectAnswer extends StatefulWidget {
  const CorrectAnswer({super.key});

  @override
  _CorrectAnswerState createState() => _CorrectAnswerState();
}

class _CorrectAnswerState extends State<CorrectAnswer> {
  // Quiz data: List of questions with images, correct answers, and options
  final List<Map<String, dynamic>> questions = [
    {
      'image': 'images/apple.png',
      'question': 'Identify from the picture:',
      'options': ['स्याउ', 'सुन्तला', 'केरा', 'आप'],
      'answer': 'स्याउ',
    },
    {
      'image': 'images/elephant.png',
      'question': 'Identify from the picture:',
      'options': ['भाघ', 'हात्ती', 'कुकुर', 'गाई'],
      'answer': 'हात्ती',
    },
    {
      'image': 'images/vegetables.png',
      'question': 'Identify from the picture:',
      'options': [ 'फलफुल', 'तरकारी','भात', 'बर्गर'],
      'answer': 'तरकारी',
    },
    {
      'image': 'images/mother.png',
      'question': 'Identify from the picture:',
      'options': ['बुवा', 'दाइ', 'बहिनी', 'आमा'],
     'answer': 'आमा',
    },
    // Add more questions as needed
  ];

  int currentQuestion = 0; // To track the current question
  int score = 0; // To track the score
  bool isAnswered = false; // To check if the current question is answered
  String selectedOption = ''; // To track the selected option

  // Method to check the answer
  void checkAnswer(String selected) {
    if (isAnswered) return;

    setState(() {
      selectedOption = selected;
      isAnswered = true;
      if (selected == questions[currentQuestion]['answer']) {
        score++;
      }
    });
  }

  // Method to go to the next question
  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        isAnswered = false;
        selectedOption = '';
      });
    } else {
      // Show score after the last question
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(score: score, total: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.orange.shade100,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.orange.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromARGB(255, 168, 165, 0), width: 4),
              ),
              child: Image.asset(
                question['image'],
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            // Display question
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromARGB(255, 173, 179, 8), width: 2),
              ),
              child: Text(
                question['question'],
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 3, 0, 8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            // Display options
            Expanded(
              child: ListView.builder(
                itemCount: question['options'].length,
                itemBuilder: (context, index) {
                  final option = question['options'][index];
                  return GestureDetector(
                    onTap: () => checkAnswer(option),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isAnswered
                            ? option == question['answer']
                                ? Colors.green.shade300
                                : option == selectedOption
                                    ? Colors.red.shade300
                                    : Colors.white
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAnswered && option == question['answer']
                              ? Colors.green
                              : Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 4, 2, 6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Next button
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Result screen to display total score
class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({super.key, required this.score, required this.total});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: const Color.fromARGB(255, 130, 17, 156),
      ),
      body: Container(
        // Use a BoxDecoration with an image as the background
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/cong.png'), // Replace with your image path
            fit: BoxFit.cover, // Make sure the image covers the whole background
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // Semi-transparent background to make text stand out
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromARGB(255, 154, 37, 204), width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Score: $score / $total',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reset and go back to the quiz screen from the beginning
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CorrectAnswer()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    backgroundColor: const Color.fromARGB(255, 187, 133, 207),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Restart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}