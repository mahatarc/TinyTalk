import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AlphabetPage extends StatefulWidget {
  final int startLetterIndex;
  final VoidCallback onFinish;

  const AlphabetPage({super.key, required this.startLetterIndex, required this.onFinish});

  @override
  _AlphabetPageState createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  final List<String> _alphabets = ['क', 'ख', 'ग', 'घ', 'ङ'];
  final List<String> _backgroundImages = [
    'images/alp1.png', 'images/alp2.png', 'images/alp3.png', 'images/alp4.png', 'images/alp5.png',
    // 'images/alp6.png', 'images/alp7.png', 'images/alp8.png', 'images/alp9.png', 'images/alp10.png',
    // 'images/alp11.png', 'images/alp12.png', 'images/alp13.png', 'images/alp14.png', 'images/alp15.png',
    // 'images/alp16.png', 'images/alp17.png', 'images/alp18.png', 'images/alp19.png', 'images/alp20.png',
    // 'images/alp21.png', 'images/alp22.png', 'images/alp23.png', 'images/alp24.png', 'images/alp25.png',
    // 'images/alp26.png', 'images/alp27.png', 'images/alp28.png', 'images/alp29.png', 'images/alp30.png',
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder.openRecorder();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  void _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/${_alphabets[widget.startLetterIndex]}.wav'));
      print('Audio played successfully');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!await Permission.microphone.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
      return;
    }

    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDir.path}/recording.aac';

    print("Recording will be saved to: $filePath");

    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
    });

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );
  }

  Future<void> _stopRecording() async {
    String? filePath = await _recorder.stopRecorder();
    print("Recording saved to: $filePath");

    setState(() {
      _isRecording = false;
      _recordedFilePath = filePath;
    });

    if (filePath != null) {
      File audioFile = File(filePath);
      if (await audioFile.exists()) {
        print("File exists at: ${audioFile.path}");
        await _evaluateSpeech_asr(audioFile);
      } else {
        print("File does not exist at: ${audioFile.path}");
      }
    } else {
      print("No file path returned from stopRecorder");
    }
  }

  Future<void> _evaluateSpeech_asr(File audioFile) async {
    const String apiUrl = "http://192.168.1.72:8000/api/deploy/evaluate_speech_asr/";

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl))
        ..fields['letter'] = _alphabets[widget.startLetterIndex] 
        ..files.add(await http.MultipartFile.fromPath("file", audioFile.path));

      print("Request Details: ");
      print("Letter: ${_alphabets[widget.startLetterIndex]}");
      print("File: ${audioFile.path}");

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("Response: $responseData");

      if (response.statusCode == 200) {
        var result = jsonDecode(responseData);
        double accuracy = (result['accuracy'] is int)
            ? (result['accuracy'] as int).toDouble()
            : result['accuracy'];
        _showResultDialog(accuracy);
      } else {
        print("Error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("API Request Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Request Error: $e')),
      );
    }
  }

  void _showResultDialog(double accuracy) {
    String message = accuracy >= 0.8
        ? "Correct pronunciation"
        : "Incorrect pronunciation, try again";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Evaluation Result"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    final isLastAlphabetInStage = widget.startLetterIndex % 5 == 4;
    final backgroundImage = _backgroundImages[widget.startLetterIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content area
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30.0),
              SizedBox(height: 500.0),
            ],
          ),
          // Microphone button
          Positioned(
            bottom: 110.0,
            left: 160.0,
            child: GestureDetector(
              onTap: _toggleRecording,
              child: Icon(
                Icons.mic,
                size: 80.0,
                color: _isRecording ? Colors.red : Colors.black,
              ),
            ),
          ),
          // Speaker button
          Positioned(
      bottom: 600.0,
      left: 30.0,// Move it to the left side
    child: IconButton(
    icon: const Icon(Icons.volume_up, size: 40.0),
    onPressed: _playSound,  // Ensure it triggers _playSound when clicked
  ),
),
          // Next/Finish button with an image background at bottom right
          Positioned(
            bottom: 20.0, // Adjust to place it right at the bottom
            right: 20.0, // Adjust to place it at the right
            child: InkWell(
              onTap: isLastAlphabetInStage
                  ? widget.onFinish // Trigger onFinish when it's the last alphabet
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlphabetPage(
                            startLetterIndex: widget.startLetterIndex + 1,
                            onFinish: widget.onFinish,
                          ),
                        ),
                      );
                    },
              child: Image.asset(
                'images/play.png', // Your image for the button bac kground
                width: 120.0, // Adjust the size
                height: 120.0, // Adjust the size
              ),
            ),
          ),
        ],
      ),
    );
  }
}