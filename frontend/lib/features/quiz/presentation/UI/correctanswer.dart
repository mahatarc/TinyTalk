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
  // int score = 0;
  String latest_score = '0';
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

  // Track rewards for each difficulty
  int easyReward = 0;
  int mediumReward = 0;
  int hardReward = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeDifficulty();
    // _loadScore();
    fetchQuestion();
  }

  Future<void> _initializeDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentDifficulty = prefs.getString('difficulty') ?? 'easy';
    prefs.setString('difficulty', currentDifficulty);
  }

  // Future<void> _loadScore() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     score = prefs.getInt('quiz_score') ?? 0;
  //   });
  // }

  // Future<void> _saveScore() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setInt('quiz_score', score);
  // }

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
        // score += 10;
        correctAnswers++;
      });
      // _saveScore();
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
    Future<Map<String, String>> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      return {"error": "No access token found"};
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.2:8000/profile/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return {
          "username": data['username'] ?? 'Unknown User',
          "email": data['email'] ?? 'No email available',
          "latest_score": data['latest_score']?.toString() ?? '0',
        };
      } else {
        return {"error": "Failed to load profile"};
      }
    } catch (e) {
      return {"error": "Network error: ${e.toString()}"};
    }
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

 // Fetch latest score
    Map<String, String> profileData = await fetchProfile();
    setState(() {
      latest_score = profileData['latest_score'] ?? '0'; // Set the latest score from the profile data
    });

    // // Update the reward based on the difficulty
    // if (currentDifficulty == 'easy') {
    //   easyReward = score;  // Assuming the score is the reward for that level
    // } else if (currentDifficulty == 'medium') {
    //   mediumReward = score;
    // } else if (currentDifficulty == 'hard') {
    //   hardReward = score;
    // }

    // Show dialog
    showDialog(
      context: context,
       barrierDismissible: false,
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
                  currentDifficulty == 'hard'
                      ? "You have completed all levels!\n Your total score till now is: $latest_score"
                      : "You have cleared $currentDifficulty level.\nYour total score till now is: $latest_score\nProceed to the next level.",
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
                      if (currentDifficulty == 'hard') {
                        // After hard level, show the total rewards screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizCompletionScreen(totalScore: int.parse(latest_score)),
                          ),
                        );
                      } else {
                        increaseDifficulty();
                        fetchQuestion();
                      }
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
  }

  void increaseDifficulty() {
    setState(() {
      correctAnswers = 0;
      questionIndex = 0;
      levelCleared = false;
    });
    // After clearing easy, medium, or hard, increase difficulty.
    if (currentDifficulty == 'easy') {
      currentDifficulty = 'medium';
    } else if (currentDifficulty == 'medium') {
      currentDifficulty = 'hard';
    }
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

class QuizCompletionScreen extends StatefulWidget {
  final int totalScore;

  QuizCompletionScreen({required this.totalScore});

  @override
  _QuizCompletionScreenState createState() => _QuizCompletionScreenState();
}

class _QuizCompletionScreenState extends State<QuizCompletionScreen> {
  // Variables to hold the state of the quiz, such as the current question, difficulty, etc.
  var question;
  String latest_score = '0';
  String currentDifficulty = 'easy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bgggg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white.withOpacity(0.7),
                  child: Icon(
                    Icons.star_rounded, 
                    size: 70, 
                    color: Colors.yellow.shade700,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 22, 129, 17),
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Your Total Score:",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color.fromARGB(255, 22, 129, 17),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${widget.totalScore}',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade700,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _restartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Restart Quiz"),
                ),
                ElevatedButton(
                  onPressed: () {
                   
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

Future<void> _restartQuiz() async {
  // Show a confirmation dialog before restarting the quiz
  bool? shouldRestart = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
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
                    color: Color.fromARGB(255, 233, 83, 83),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 35,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('images/alert.png'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Warning!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "You will lose all your progress. \n \n Are you sure you want to continue?",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); 
            },
            child: Text("Continue"),
          ),
        ],
      );
    },
  );

  // If the user confirmed, restart the quiz
  if (shouldRestart == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      print('No access token found');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.2:8000/api/restart_quiz/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          question = null;
          latest_score = data['latest_score'].toString();
          currentDifficulty = data['last_difficulty'];
          List<dynamic> questions = data['questions'];
          if (questions.isNotEmpty) {
            question = questions[0];
          }
        });

        // Show a success message (Snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Quiz has been restarted successfully! Go ahead and do the quiz again."),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Failed to restart quiz');
      }
    } catch (e) {
      print("Error restarting quiz: $e");


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to restart quiz. Please try again."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  } else {
   
    print("Quiz restart canceled.");
  }
}



}
