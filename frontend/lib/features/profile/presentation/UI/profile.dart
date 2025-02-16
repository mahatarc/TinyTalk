import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile(); // Call the fetch profile function on widget initialization
  }

  // Function to fetch the profile data
  Future<void> _fetchProfile() async {
    try {
      // Replace with the correct API endpoint
      final response = await http.get(Uri.parse('http://192.168.1.5:8000/api/profile/'));

      if (response.statusCode == 200) {
        // Parse the JSON response from the backend
        var data = json.decode(response.body);

        setState(() {
          // Check if the data fields are null, otherwise set the values
          username = data['username'] ?? 'Default Username';
          email = data['email'] ?? 'No Email Provided';
        });
      } else {
        // If the response status is not 200, print an error
        print('Error fetching profile: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error occurred while fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the username and email in text widgets
            Text('Username: $username', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}