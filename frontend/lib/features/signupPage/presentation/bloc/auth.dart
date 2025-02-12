import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupService {
  final String apiUrl = "http://192.168.1.9:8000/api/signup/";  // Use your machine's IP address

Future<Map<String, dynamic>> signup(String username, String email, String password) async {
  try {
    print("Attempting to call API at: $apiUrl");  // Debugging line

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    print("Response status code: ${response.statusCode}");  // Log status code
    print("Response body: ${response.body}");  // Log raw response body

    if (response.statusCode == 201) {
      return {"success": true, "message": "User created successfully"};
    } else {
      final errorResponse = json.decode(response.body);
      return {
        "success": false,
        "message": errorResponse['detail'] ?? 'An unknown error occurred'
      };
    }
  } catch (e) {
    print("Error while calling API: $e");  // Debugging line
    return {"success": false, "message": "An error occurred: $e"};
  }
}
}