import 'package:flutter/material.dart';

class CorrectAnswer extends StatefulWidget {
  @override
  _CorrectAnswerState createState() => _CorrectAnswerState();
}

class _CorrectAnswerState extends State<CorrectAnswer> {
  
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
      'options': ['बाघ', 'हात्ती', 'कुकुर', 'गाई'],
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
        backgroundColor: const Color.fromARGB(255, 116, 233, 98),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg2.jpg'), // Replace with your background image path
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display image
            Column(
              children: [
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
              ],
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
            // Next button with wooden image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('images/h1.png'), // Wooden button texture
                  fit: BoxFit.cover,
                ),
              ),
              child: ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent, // Make button transparent to show wooden texture
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.transparent, // Remove shadow for cleaner look
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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

  ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: const Color.fromARGB(255, 33, 159, 100),
        elevation: 0, // No shadow
      ),
      body: Container(
        // Use a BoxDecoration with an image as the background
        decoration: BoxDecoration(
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
              border: Border.all(color: const Color.fromARGB(255, 36, 166, 86), width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Score: $score / $total',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 27, 215, 71),
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
                    backgroundColor: const Color.fromARGB(255, 133, 207, 153),
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
