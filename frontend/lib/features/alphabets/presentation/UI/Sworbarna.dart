import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:tiny_talks/config.dart';

class Sworbarna extends StatefulWidget {
  
  const Sworbarna({super.key});

  @override
  _SworbarnaState createState() => _SworbarnaState();
}

class _SworbarnaState extends State<Sworbarna> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _recordedFilePath;
  int _currentSworbarnaIndex = 0;

  final List<String> _sworbarna = [
    'अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ', 'अं', 'अः'
  ];
  final List<String> _backgroundImages = [
    'images/swo1.png', 'images/swo2.png', 'images/swo3.png', 'images/swo4.png',
    'images/swo5.png', 'images/swo6.png', 'images/swo8.png',
    'images/swo9.png', 'images/swo10.png', 'images/swo11.png', 'images/swo12.png',
    'images/swo13.png'
  ]; 
  


  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder.openRecorder();
      await _player.openPlayer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  void _playSound() async {
   try {
      await _audioPlayer.play(AssetSource('audio/${_sworbarna[_currentSworbarnaIndex]}.wav'));
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
        await _evaluateSpeech(audioFile);
      } else {
        print("File does not exist at: ${audioFile.path}");
      }
    } else {
      print("No file path returned from stopRecorder");
    }
  }

  void _nextSworbarna() {
    setState(() {
      if (_currentSworbarnaIndex < _sworbarna.length - 1) {
        _currentSworbarnaIndex++;
      } else {
        _currentSworbarnaIndex = 0; // Reset to the first Sworbarna if it reaches the end
      }
    });
  }
Future<void> _evaluateSpeech(File audioFile) async {
    const String apiUrl = "${AppConfig.baseUrl}/api/deploy/evaluate_speech/";

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl))
        ..fields['label'] = _sworbarna[_currentSworbarnaIndex] 
        ..files.add(await http.MultipartFile.fromPath("file", audioFile.path));

      print("Request Details: ");
      print("label: ${_sworbarna[_currentSworbarnaIndex]}");
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
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              _backgroundImages[_currentSworbarnaIndex], // Dynamically change background image
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 550.0,
              left: 30.0,
              child: IconButton(
                icon: const Icon(Icons.volume_up, size: 40.0),
                onPressed: _playSound,
              ),
            ),
            Positioned(
              bottom: 200.0,
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Icon(
                  Icons.mic,
                  size: 80.0,
                  color: _isRecording ? Colors.red : Colors.black,
                ),
              ),
            ),
            // "Next" button with background image at bottom-right
            Positioned(
              bottom: 30.0,
              right: 30.0, // Align to the right instead of left
              child: InkWell(
                onTap: _nextSworbarna,
                child: Image.asset(
                  'images/play.png', // Path to the "next.png" image
                  width: 100.0, // Adjust the size as needed
                  height: 100.0, // Adjust the size as needed
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
