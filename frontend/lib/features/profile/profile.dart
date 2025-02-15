import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg99.jpg'), // Background image
            fit: BoxFit.cover, // Ensure the background covers the screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              const SizedBox(height: 100),

              // Profile Picture with circular border
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('images/profile.png'), // User's profile image
                backgroundColor: Colors.green, // Jungle color to match theme
              ),
              const SizedBox(height: 20),

              // Name with background image for better visibility
              Container(
                width: double.infinity,
                height: 70, // Set height for the container
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/h1.png'), // Image for text background
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'JohnDoe', // Replace with dynamic name
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for visibility
                    fontFamily: 'Quicksand',
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
              ),
              const SizedBox(height: 10),

              // Email with background image for better visibility
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/h1.png'), // Image for text background
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'johndoe@example.com', // Replace with dynamic email
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white, // White text for visibility
                    fontFamily: 'Quicksand',
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
              ),
              const SizedBox(height: 10),

              // Score Points with background image for better visibility
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/h1.png'), // Image for text background
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Score: 150 Points', // Replace with dynamic score
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white, // White text for visibility
                    fontFamily: 'Quicksand',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

             
              //const SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: () {
                  // Add your logout functionality here
                  print("Logged out");
                  // Navigate to login or home page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
