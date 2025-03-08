import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';
import 'package:tiny_talks/features/homepage/presentation/UI/homepage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, String>> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      return {"error": "No access token found"};
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.5:8000/profile/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return {
          "username": data['username'] ?? 'Unknown User',
          "email": data['email'] ?? 'No email available',
          "score": data['latest_score']?.toString() ?? '0',
        };
      } else {
        return {"error": "Failed to load profile"};
      }
    } catch (e) {
      return {"error": "Network error: ${e.toString()}"};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg99.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<Map<String, String>>(
          future: fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data?["error"] != null) {
              return Center(
                child: Text(
                  snapshot.data?["error"] ?? "Error loading profile",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            // Extracting user data
            String username = snapshot.data!["username"]!;
            String email = snapshot.data!["email"]!;
            String score = snapshot.data!["score"]!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('images/profile.png'),
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 20),
                buildInfoContainer(username),
                buildInfoContainer(email),
                buildInfoContainer(score),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove("access_token"); // Logout action
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false, // Remove all routes from the stack
                    );
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
            );
          },
        ),
      ),
    );
  }

  Widget buildInfoContainer(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Quicksand'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
