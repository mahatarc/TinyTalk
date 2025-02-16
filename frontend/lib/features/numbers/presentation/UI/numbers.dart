import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Numbers extends StatefulWidget {
  const Numbers({super.key});

  @override
  _NumbersState createState() => _NumbersState();
}

class _NumbersState extends State<Numbers> {
  final List<String> _numbers = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  ];

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

  int _currentNumberIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _nextNumber() {
    setState(() {
      if (_currentNumberIndex < _numbers.length - 1) {
        _currentNumberIndex++;
      } else {
        _currentNumberIndex = 0; // Reset to the first number if it reaches the end
      }
    });
  }

  // Function to play the corresponding audio
void _playAudio() async {
  // Ensure you're using the correct method to load the audio file
  await _audioPlayer.setSource(AssetSource('audio/${_numbers[_currentNumberIndex]}.wav'));
  await _audioPlayer.resume(); // Play the audio
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
              _backgroundImages[_currentNumberIndex], // Dynamically change background image
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 550.0,
              left: 30.0,
              child: IconButton(
                icon: const Icon(Icons.volume_up, size: 40.0),
                onPressed: _playAudio, // Play the corresponding audio when volume button is pressed
              ),
            ),
            Positioned(
              bottom: 200.0,
              child: GestureDetector(
                onTap: () {
                  // Removed recording toggle logic
                },
                child: Icon(
                  Icons.mic,
                  size: 80.0,
                  color: Colors.black, // Default mic color
                ),
              ),
            ),
            // "Next" button with background image at bottom-right
            Positioned(
              bottom: 40.0,
              right: 30.0, // Align to the right instead of left
              child: InkWell(
                onTap: _nextNumber,
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
