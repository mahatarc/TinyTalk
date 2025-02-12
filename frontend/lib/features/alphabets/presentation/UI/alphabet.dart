import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AlphabetPage extends StatefulWidget {
  final int startLetterIndex;
  final VoidCallback onFinish;

  const AlphabetPage({super.key, required this.startLetterIndex, required this.onFinish});

  @override
  _AlphabetPageState createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  // Define the alphabets in stages
  final List<String> _alphabets = [
    'क', 'ख', 'ग', 'घ', 'ङ', 'च', 'छ', 'ज', 'झ', 'ञ', 'ट', 'ठ', 'ड', 'ढ', 'ण',
    'त', 'थ', 'द', 'ध', 'न', 'प', 'फ', 'ब', 'भ', 'म', 'य', 'र', 'ल', 'व', 'श', 'ष'
  ];

  // Define the backgrounds (update these with your image paths)
  final List<String> _backgroundImages = [
'images/alp1.png',
    'images/alp2.png',  
    'images/alp3.png',
    'images/alp4.png',
    'images/alp5.png',
    'images/alp6.png',
    'images/alp7.png',
    'images/alp8.png',
    'images/alp9.png',
    'images/alp10.png',
    'images/alp11.png',
    'images/alp12.png',
    'images/alp13.png',
    'images/alp14.png',
    'images/alp15.png',
    'images/alp16.png',
    'images/alp17.png',
    'images/alp18.png',
    'images/alp19.png',
    'images/alp20.png',
    'images/alp21.png',
    'images/alp22.png',
    'images/alp23.png',
    'images/alp24.png',
    'images/alp25.png',
    'images/alp26.png',
    'images/alp27.png',
    'images/alp28.png',
    'images/alp29.png',
    'images/alp30.png',
    
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  final String _filePath = 'recording.aac';

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
      await _audioPlayer.play(DeviceFileSource('audio/${_alphabets[widget.startLetterIndex]}.mp3'));
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
            bottom: 720.0,
            right: 30.0,
            child: IconButton(
              icon: const Icon(Icons.volume_up, size: 40.0),
              onPressed: _playSound,
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
