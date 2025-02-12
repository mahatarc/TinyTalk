import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class Numbers extends StatefulWidget {


  const Numbers({super.key});
  @override
  _NumbersState createState() => _NumbersState();
}

class _NumbersState extends State<Numbers> {
 final List<String> _numbers = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  ];

   final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  final String _filePath = 'recording.aac';

  final List<String> _backgroundImages = [
     'images/0.png',  
    'images/1.png',
    'images/2.png',
    'images/3.png',
    'images/4.png',
    'images/5.png',
    'images/6.png',
    'images/7.png',
    'images/8.png',
    'images/9.png',
  ]; 
  
  int _currentSworbarnaIndex = 0;

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
      await _audioPlayer.play(DeviceFileSource('audio/${_numbers[_currentSworbarnaIndex]}.mp3'));
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
    if (await Permission.microphone.isGranted) {
      setState(() {
        _isRecording = true;
      });
      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  void _nextSworbarna() {
    setState(() {
      if (_currentSworbarnaIndex < _numbers.length - 1) {
        _currentSworbarnaIndex++;
      } else {
        _currentSworbarnaIndex = 0; // Reset to the first Sworbarna if it reaches the end
      }
    });
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
              bottom: 40.0,
              right: 30.0, // Align to the right instead of left
              child: InkWell(
                onTap: _nextSworbarna,
                child: Image.asset(
                  'images/play.png', // Path to the "next.png" image
                  width: 60.0, // Adjust the size as needed
                  height: 60.0, // Adjust the size as needed
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


