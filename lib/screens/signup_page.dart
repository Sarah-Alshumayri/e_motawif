import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  String? _selectedIdType;
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Function to show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Function to attempt sign-up and store data in SharedPreferences
  Future<void> _attemptSignUp() async {
    const String apiUrl = "http://192.168.56.1/e_motawif_new/sign_up.php";

    Map<String, dynamic> requestBody = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "phone": _phoneController.text.trim(),
      "id_type": _selectedIdType,
      "id_number": _idNumberController.text.trim(),
      "dob": _dobController.text.trim(),
      "role": "pilgrim",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // ✅ Store user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("name", _nameController.text.trim());
        prefs.setString("email", _emailController.text.trim());
        prefs.setString("phone", _phoneController.text.trim());
        prefs.setString("idType", _selectedIdType!);
        prefs.setString("idNumber", _idNumberController.text.trim());
        prefs.setString("dob", _dobController.text.trim());
        prefs.setString("role", "pilgrim");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Sign-up successful!"),
              backgroundColor: Colors.green),
        );

        // Navigate to Login Page
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      _showError("Network error, please try again.");
    }
  }

  // Function to show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4A45),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.asset('assets/images/e_motawif_logo.png',
                          height: 130),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Create New Account",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "First and Last Name"),
                const SizedBox(height: 20),
                _buildTextField(_emailController, "E-Mail"),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildTextField(_phoneController, "Phone Number"),
                const SizedBox(height: 20),
                _buildDropdown(),
                const SizedBox(height: 20),
                if (_selectedIdType != null)
                  _buildTextField(_idNumberController,
                      "Enter your $_selectedIdType number"),
                const SizedBox(height: 20),
                _buildDateField(),
                const SizedBox(height: 30),
                _buildSignUpButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Password",
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
      ),
      items: ["National ID", "Iqama", "Passport"]
          .map((type) =>
              DropdownMenuItem<String>(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => setState(() => _selectedIdType = value),
      hint: const Text("Select Identification Type"),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dobController,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Date of Birth",
        suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _attemptSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        child: const Text("Sign Up",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage())),
        child: const Text("Have an account? Log In",
            style: TextStyle(
                color: Colors.white, decoration: TextDecoration.underline)),
      ),
    );
  }
}
