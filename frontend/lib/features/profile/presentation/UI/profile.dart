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
  String username = '';
  String email = '';

  // Fetch user profile from the backend
  Future<void> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      print('No access token found');
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.70:8000/profile/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        username = data['username'];
        email = data['email'];
      });
    } else {
      print('Failed to load profile');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('images/profile.png'),
                backgroundColor: Colors.green,
              ),
              const SizedBox(height: 20),
              buildInfoContainer(username),
              buildInfoContainer(email),
              buildInfoContainer("Score: 150 Points"),
              const SizedBox(height: 10),
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
          ),
        ),
      ),
    );
  }

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