import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
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
        Uri.parse("http://192.168.1.5:8000/api/password_reset/"), // Your Django backend URL
        headers: {"Content-Type": "application/json"},
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
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Enter your email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                    color: message!.contains("sent")
                        ? Colors.green
                        : Colors.red),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : sendResetRequest,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text("Send Reset Email"),
            ),
          ],
        ),
      ),
    );
  }
}
