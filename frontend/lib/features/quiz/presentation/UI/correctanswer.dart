import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tiny_talks/config.dart'; 

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
  bool levelCleared = false;
  late AudioPlayer _audioPlayer;
  String audioUrl = '';
  String audioImage = '';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeDifficulty();
    _loadScore();
    fetchQuestion();
  }

  Future<void> _initializeDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentDifficulty = prefs.getString('difficulty') ?? 'easy';
    prefs.setString('difficulty', currentDifficulty);
  }

  Future<void> _loadScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt('quiz_score') ?? 0;
    });
  }

  Future<void> _saveScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('quiz_score', score);
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
        Uri.parse('${AppConfig.baseUrl}/api/adaptive_quiz/?difficulty=$currentDifficulty'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data != null && data is Map<String, dynamic> && data.containsKey('question_text')) {
          setState(() {
            question = data;
            isAnswered = false;
            selectedOption = '';
            totalQuestions++;

            audioUrl = question?['audio'] ?? '';
            audioImage = question?['image'] ?? '';
          });
        } else {
          _showLevelClearedMessage();
        }
      } else if (response.statusCode == 404 && response.body.contains('No more questions')) {
        _showLevelClearedMessage();
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

    String? correctAnswer = question?['answer'];
    bool isCorrect = correctAnswer != null && selected.trim() == correctAnswer.trim();

    if (isCorrect) {
      setState(() {
        score += 10;
        correctAnswers++;
      });
      _saveScore();
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/answer/'),
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
        if (data.containsKey('next_difficulty')) {
          setState(() {
            currentDifficulty = data['next_difficulty'];
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('difficulty', currentDifficulty);
        }
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

    // Show dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 124, 151, 119),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('images/cong.png'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Congratulations!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "You have cleared a level.\nYour difficulty will now be increased.\nYour total score till now is: $score\nProceed to the next level.",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      increaseDifficulty();
                      fetchQuestion();
                    },
                    child: Text("Proceed", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    // Debug log
    print("Current difficulty: $currentDifficulty");

    // Show results only when user has completed "hard" difficulty
    if (currentDifficulty == 'hard') {
      print("Hard mode completed! Navigating to results screen.");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizCompletionScreen(totalScore: score),
        ),
      );
    }
  }

  void increaseDifficulty() {
    setState(() {
      correctAnswers = 0;
      questionIndex = 0;
      levelCleared = false;
    });
  }

  Widget _buildOption(String option) {
    String? correctAnswer = question?['answer'];
    bool isCorrect = correctAnswer != null && option.trim() == correctAnswer.trim();
    bool isSelected = option == selectedOption;

    Color optionColor = Colors.white;
    if (isAnswered) {
      if (isCorrect) {
        optionColor = Colors.green.shade300;
      } else if (isSelected) {
        optionColor = Colors.red.shade300;
      }
    }

    return GestureDetector(
      onTap: () => submitAnswer(option),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: optionColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          option,
          style: GoogleFonts.notoSans(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _playAudio() async {
    if (audioUrl.isNotEmpty) {
      await _audioPlayer.play(AssetSource(audioUrl));
    } else {
      print("Audio file is empty!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return Scaffold(appBar: AppBar(title: const Text("Loading...")), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/quizbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (question?['image'] != null)
                GestureDetector(
                  onTap: _playAudio,
                  child: Image.asset(audioImage, height: 200),
                ),
              SizedBox(height: 16),
              Text(question?['question_text'] ?? 'No question', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              if (question?['options'] != null)
                ...question!['options'].map<Widget>((opt) => _buildOption(opt)).toList(),
              if (isAnswered) ElevatedButton(onPressed: nextQuestion, child: Text("Next")),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizCompletionScreen extends StatelessWidget {
  final int totalScore;

  QuizCompletionScreen({required this.totalScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz Completed")),
      body: Center(
        child: Text("Your Total Score: $totalScore", style: TextStyle(fontSize: 30)),
      ),
    );
  }
}
