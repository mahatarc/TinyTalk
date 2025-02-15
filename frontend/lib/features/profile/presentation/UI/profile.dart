import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;

  const ProfilePage({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg99.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              // Profile Picture
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('images/profile.png'),
                backgroundColor: Colors.green,
              ),
              const SizedBox(height: 20),
              // Name Field (Dynamic)
              buildInfoContainer(name),
              // Email Field (Dynamic)
              buildInfoContainer(email),
              // Score (Static for now, make dynamic later)
              buildInfoContainer("Score: 150 Points"),
              const SizedBox(height: 10),
              // Logout Button
              ElevatedButton(
                onPressed: () {
                  // Add logout functionality here
                  print("Logged out");
                  Navigator.pop(context); // Navigate back to login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Quicksand'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Widget for Info Containers
  Widget buildInfoContainer(String text) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('images/h1.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Quicksand'),
        textAlign: TextAlign.center,
      ),
    );
  }
}