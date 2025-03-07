import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class CorrectAnswer extends StatefulWidget {
  @override
  _CorrectAnswerState createState() => _CorrectAnswerState();
}

class _CorrectAnswerState extends State<CorrectAnswer> {
  Map<String, dynamic>? question;
  int score = 0;
  bool isAnswered = false;
  String selectedOption = '';
  String currentDifficulty = 'easy';
  int questionIndex = 0;
  int correctAnswers = 0;
  int totalQuestions = 0;
  bool levelCleared = false;  //prevent further question fetching

  @override
  void initState() {
    super.initState();
    _initializeDifficulty();
    fetchQuestion();
  }

  Future<void> _initializeDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedDifficulty = prefs.getString('difficulty');

    if (storedDifficulty == null) {
      prefs.setString('difficulty', 'easy');
      currentDifficulty = 'easy';
    } else {
      currentDifficulty = storedDifficulty;
    }
  }

  Future<void> fetchQuestion() async {
    if (levelCleared) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      print('No access token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8000/api/adaptive_quiz/?difficulty=$currentDifficulty'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print("Fetched question data: $data");

        if (data != null && data is Map<String, dynamic>) {
          if (data.containsKey('question_text') && data.containsKey('options')) {
            setState(() {
              question = Map<String, dynamic>.from(data);
              isAnswered = false;
              selectedOption = '';
              totalQuestions++;
            });
          } else {
            print("No valid question data received. Proceeding to next level.");
            _showLevelClearedMessage();
            // Navigate to result screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(total: score), 
              ),
            );
          }
        } else {
          print("Invalid data format received");
        }
      } else if (response.statusCode == 404 && response.body.contains('No more questions in this difficulty')) {
        _showLevelClearedMessage();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(total: score), 
          ),
        );
      } else {
        throw Exception('Failed to load question');
      }
    } catch (e) {
      print("Error fetching question: $e");
      await Future.delayed(Duration(seconds: 2));
      fetchQuestion();
    }
  }

  Future<void> submitAnswer(String selected) async {
    if (isAnswered) return;

    setState(() {
      selectedOption = selected;
      isAnswered = true;
    });

    final correctAnswer = question?['answer'] ?? '';
    bool isCorrect = selected.trim() == correctAnswer.trim();

    if (isCorrect) {
      setState(() {
        score += 10;  // 10 points per correct answer
        correctAnswers++;
      });
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8000/api/answer/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode({
          'question_id': question?['id'],
          'answer': selected,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentDifficulty = data['next_difficulty'];
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('difficulty', currentDifficulty);
      } else {
        throw Exception('Failed to submit answer');
      }
    } catch (e) {
      print("Error submitting answer: $e");
    }
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  void nextQuestion() {
    setState(() {
      questionIndex++;
      isAnswered = false;
      selectedOption = '';
    });
    fetchQuestion();
  }

  void _showLevelClearedMessage() async {
    setState(() {
      levelCleared = true; 
    });


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text(
            "You have cleared a level.\nYour difficulty will now be increased.\nYour total score till now is: $score\nProceed to next level.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                increaseDifficulty();
              },
              child: Text("Proceed"),
            ),
          ],
        );
      },
    );
  }

  void increaseDifficulty() {
    setState(() {
      correctAnswers = 0;
      questionIndex = 0;
      currentDifficulty = 'medium';  
    });
    fetchQuestion();
  }

  Widget _buildOption(String option) {
    String correctAnswer = question?['answer'] ?? '';

    bool isCorrect = option.trim() == correctAnswer.trim();
    bool isSelected = option == selectedOption;

    Color optionColor;
    if (isAnswered) {
      if (isCorrect) {
        optionColor = Colors.green.shade300;
      } else if (isSelected) {
        optionColor = Colors.red.shade300;
      } else {
        optionColor = Colors.white;
      }
    } else {
      optionColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => submitAnswer(option),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: optionColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAnswered && isCorrect ? Colors.green : Colors.deepPurple,
            width: 2,
          ),
        ),
        child: Text(
          option,
          style: GoogleFonts.notoSans(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 116, 233, 98),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (question != null && question!['image'] != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('${question!['image']}'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              question?['question_text'] ?? 'Question not available',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (question?['options'] != null && question?['options'] is List)
              ...List.generate(
                question!['options'].length,
                (index) => _buildOption(question!['options'][index]),
              ),
            const SizedBox(height: 20),
            if (isAnswered)
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text("Next", style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int total;

  const ResultScreen({Key? key, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Quiz Result"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your total score is: $total',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
