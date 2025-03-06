import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? message;

  Future<void> sendResetRequest() async {
    final String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        message = "Please enter your email.";
      });
      return;
    }
    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.70:8000/api/password_reset/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          message = "Password reset email sent! Check your inbox.";
        });
      } else {
        setState(() {
          message = responseData["message"] ?? "Something went wrong.";
        });
      }
    } catch (e) {
      setState(() {
        message = "Failed to connect to the server.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            color: Colors.black, // Brown color for the title text
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(
          color: Colors.black, // Set the back arrow color to black
        ),
      ),
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/logbg.png'), // Background image
            fit: BoxFit.cover, // Cover the screen with the background
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email TextField
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Enter your email",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70, // Slightly transparent white background
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Message display
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(
                    color: message!.contains("sent") ? Colors.green : Colors.red,
                  ),
                ),
              const SizedBox(height: 10),

              // Send Reset Email button
              ElevatedButton(
                onPressed: isLoading ? null : sendResetRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // Button background color
                  foregroundColor: Colors.green, // Text color
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Send Reset Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
