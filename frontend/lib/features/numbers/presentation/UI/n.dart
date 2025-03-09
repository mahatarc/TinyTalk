import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Numbers extends StatefulWidget {
  const Numbers({super.key});

  @override
  _NumbersState createState() => _NumbersState();
}

class _NumbersState extends State<Numbers> {
  final List<String> _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  final List<String> _backgroundImages = [
    'images/0.png', 'images/1.png', 'images/2.png', 'images/3.png',
    'images/4.png', 'images/5.png', 'images/6.png', 'images/7.png',
    'images/8.png', 'images/9.png',
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;
  int _currentNumberIndex = 0;

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

  // Updated _playSound method with the correct path
  Future<void> _playSound() async {
    String audioPath = "assets/audio/${_numbers[_currentNumberIndex]}.mp3"; // Correct path to assets folder
    try {
      await _audioPlayer.play(AssetSource(audioPath)); // Use AssetSource for assets folder
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

  // Get the app directory and set the file path with a supported file extension
  Directory appDir = await getApplicationDocumentsDirectory();
  String filePath = '${appDir.path}/recording.aac'; // Use .aac for compatibility

  // Debug: print the file path to check if it's correct
  print("Recording will be saved to: $filePath");

  setState(() {
    _isRecording = true;
    _recordedFilePath = filePath;
  });

  // Start recording with the specified file path and codec
  await _recorder.startRecorder(
    toFile: filePath,
    codec: Codec.aacADTS, // Set codec to AAC
  );
}

Future<void> _stopRecording() async {
  String? filePath = await _recorder.stopRecorder();

  // Debug: print file path after stopping the recorder
  print("Recording saved to: $filePath");

  setState(() {
    _isRecording = false;
    _recordedFilePath = filePath;
  });

  // Check if the file exists
  if (filePath != null) {
    File audioFile = File(filePath);
    if (await audioFile.exists()) {
      print("File exists at: ${audioFile.path}");
      await _evaluateSpeech(audioFile);
    } else {
      print("File does not exist at: ${audioFile.path}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File not found at: ${audioFile.path}')),
      );
    }
  } else {
    print("No file path returned from stopRecorder");
  }
}


Future<void> _evaluateSpeech(File audioFile) async {
  const String apiUrl = "http://192.168.1.72:8000/api/deploy/evaluate_speech/";

  try {
    // Prepare the multipart request
    var request = http.MultipartRequest("POST", Uri.parse(apiUrl))
      ..fields['number'] = _numbers[_currentNumberIndex]
      ..files.add(await http.MultipartFile.fromPath("file", audioFile.path));

    // Debug: Print request details
    print("Request Details: ");
    print("Number: ${_numbers[_currentNumberIndex]}");
    print("File: ${audioFile.path}");

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    // Debug: Print server response
    print("Response: $responseData");

    if (response.statusCode == 200) {
      var result = jsonDecode(responseData);
       double accuracy = (result['accuracy'] is int)
      ? (result['accuracy'] as int).toDouble()
      : result['accuracy'];
      // _showResultDialog(result['accuracy']);
    } else {
      print("Error: ${response.statusCode}");
      // Show error message from response
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Evaluation Result"),
        content: Text("Correct pronunciation"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _nextNumber() {
    setState(() {
      _currentNumberIndex = (_currentNumberIndex + 1) % _numbers.length;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioPlayer.dispose();
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              _backgroundImages[_currentNumberIndex],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 550.0,
              left: 30.0,
              child: IconButton(
                icon: const Icon(Icons.volume_up, size: 40.0),
                onPressed: _playSound, // Calls _playSound() when pressed
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
            Positioned(
              bottom: 40.0,
              right: 30.0,
              child: InkWell(
                onTap: _nextNumber,
                child: Image.asset(
                  'images/play.png',
                  width: 60.0,
                  height: 60.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
