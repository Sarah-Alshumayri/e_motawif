import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();

  // Function to show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Function to validate fields before sending
  Future<void> _attemptSend() async {
    String userId = _idController.text.trim();
    String email = _emailOrPhoneController.text.trim();

    if (userId.isEmpty) {
      _showError("ID is required.");
      return;
    }
    if (email.isEmpty) {
      _showError("Email is required.");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("http://192.168.56.1/e_motawif_new/forgot_password.php"),
        body: {"user_id": userId, "email": email},
      );

      var result = jsonDecode(response.body);

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reset email sent to ${result['email']}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError(result['message'] ?? "Something went wrong.");
      }
    } catch (e) {
      _showError("Server error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4A45), // Background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // Moves everything slightly down
            // Logo Positioned at the Top-Left
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Moves logo to the left
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 0), // Adjusted position
                  child: Image.asset(
                    'assets/images/e_motawif_logo.png', // Ensure this asset exists
                    height: 130, // Bigger logo for better visibility
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Forgot Password Title (Adjusted to match login page)
            const Text(
              "Forgot Password",
              style: TextStyle(
                fontSize: 24, // Same as the login page
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // ID Input Field
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "ID",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Email or Phone Number Input Field
            TextField(
              controller: _emailOrPhoneController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _attemptSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  "Send",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sign-Up Link
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
