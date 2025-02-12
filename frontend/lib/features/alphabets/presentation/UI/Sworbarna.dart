import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final String _filePath = 'recording.aac';

  final List<String> _sworbarna = [
    'अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ऋ', 'ए', 'ऐ', 'ओ', 'औ', 'अं', 'अः'
  ];
  final List<String> _backgroundImages = [
    'images/swo1.png', 'images/swo2.png', 'images/swo3.png', 'images/swo4.png',
    'images/swo5.png', 'images/swo6.png', 'images/swo7.png', 'images/swo8.png',
    'images/swo9.png', 'images/swo10.png', 'images/swo11.png', 'images/swo12.png',
    'images/swo13.png'
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
      await _audioPlayer.play(DeviceFileSource('audio/${_sworbarna[_currentSworbarnaIndex]}.mp3'));
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
      if (_currentSworbarnaIndex < _sworbarna.length - 1) {
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
