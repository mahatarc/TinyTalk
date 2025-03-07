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
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  String selectedOption = '';
  String currentDifficulty = 'medium'; // Default difficulty

  @override
  void initState() {
    super.initState();
    fetchQuestion(); // Fetch the first question on startup
  }

  Future<void> fetchQuestion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      print('No access token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.2:8000/api/adaptive_quiz/?difficulty=$currentDifficulty'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Fetched question data: $data");

        setState(() {
          questions.add(Map<String, dynamic>.from(data));
          currentDifficulty = data['difficulty'] ?? 'medium';
        });
      } else {
        throw Exception('Failed to load question');
      }
    } catch (e) {
      print("Error fetching question: $e");
    }
  }

  Future<void> submitAnswer(String selected) async {
    if (isAnswered) return;

    setState(() {
      selectedOption = selected;
      isAnswered = true;
    });

    final question = questions[currentQuestionIndex];
    final correctAnswer = question['answer'];

    if (selected == correctAnswer) {
      setState(() {
        score++;
      });
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.2:8000/api/answer/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode({
          'question_id': question['id'],
          'answer': selected,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentDifficulty = data['next_difficulty'];
        });
        print("Answer submitted, next difficulty: $currentDifficulty");
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
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedOption = '';
      });
    } else {
      fetchQuestion().then((_) {
        if (questions.length > currentQuestionIndex + 1) {
          setState(() {
            currentQuestionIndex++;
            isAnswered = false;
            selectedOption = '';
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(score: score, total: questions.length),
            ),
          );
        }
      });
    }
  }

  Widget _buildOption(String option, String correctAnswer) {
    String decodedOption = utf8.decode(option.codeUnits);

    return GestureDetector(
      onTap: () => submitAnswer(decodedOption),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAnswered
              ? decodedOption == correctAnswer
                  ? Colors.green.shade300
                  : decodedOption == selectedOption
                      ? Colors.red.shade300
                      : Colors.white
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAnswered && decodedOption == correctAnswer
                ? Colors.green
                : Colors.deepPurple,
            width: 2,
          ),
        ),
        child: Text(
          decodedOption,
          style: GoogleFonts.notoSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    if (question['options'] == null || question['options'].isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text("No options available for this question.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 116, 233, 98),
        elevation: 0,
        title: Text("Difficulty: $currentDifficulty"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg2.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (question['image'] != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(question['image'] ?? ''),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              question['question_text'] ?? 'Question not available',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(question['options'].length, (index) {
              final option = question['options'][index];
              return _buildOption(option, question['answer']);
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: nextQuestion,
              child: const Text("Next Question"),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({Key? key, required this.score, required this.total}) : super(key: key);

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
              'Score: $score/$total',
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
