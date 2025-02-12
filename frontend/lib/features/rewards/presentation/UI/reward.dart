import 'package:flutter/material.dart';


class RewardScreen extends StatelessWidget {
  final int coinsEarned;
  final int totalCoins;

  RewardScreen({required this.coinsEarned, required this.totalCoins});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: const Color.fromARGB(255, 243, 182, 0)),
                SizedBox(width: 2),
                Text(
                  '$totalCoins',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/rewards.jpg'), // Ensure this file exists
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0), // Move this section upwards
              child: Column(
                children: [
                  Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 114, 4, 2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'You earned:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/coin.png', // Ensure this file exists
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '$coinsEarned Coins',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 254, 153, 2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(), // Pushes content to the center
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0), // Add some padding at the bottom
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the quiz screen
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 87, 234, 92),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 18, 2, 11)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
