import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';

class PilgrimProfilePage extends StatefulWidget {
  @override
  _PilgrimProfilePageState createState() => _PilgrimProfilePageState();
}

class _PilgrimProfilePageState extends State<PilgrimProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();

  bool emailEditable = false;
  bool phoneEditable = false;
  bool hasChanges = false;

  String name = "";
  String id_type = "";
  String user_id = "";
  String? selectedSickness;

  final List<String> sicknessOptions = [
    'None',
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    if (userId == null) return;

    var result = await DatabaseHelper().getUserProfile(userId);
    if (result['status'] == 'success') {
      var user = result['data'];
      setState(() {
        name = user['name'] ?? "Unknown";
        emailController.text = user['email'] ?? "";
        phoneController.text = user['phone'] ?? "";
        id_type = user['id_type'] ?? "Unknown";
        user_id = user['user_id'] ?? "Unknown";
        dobController.text = user['dob'] ?? "";
        emergencyContactController.text = user['emergencyContact'] ?? "";
        selectedSickness = user['sickness'] ?? "None";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Failed to load user profile"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    if (userId == null) return;

    var updatedData = {
      "user_id": userId,
      "email": emailController.text,
      "phone": phoneController.text,
      "dob": dobController.text,
      "emergencyContact": emergencyContactController.text,
      "sickness": selectedSickness ?? "None",
    };

    var response = await DatabaseHelper().saveUserProfile(updatedData);

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("✅ Profile updated!"),
        backgroundColor: Colors.green,
      ));
      setState(() => hasChanges = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Failed to update profile"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dobController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        dobController.text = date.toIso8601String().split('T')[0];
        hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D4A45),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Colors.white), // ✅ Makes back arrow white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              _buildStaticField("Name", name),
              const SizedBox(height: 12),
              _buildEditableField("Email", emailController, () {
                setState(() => emailEditable = !emailEditable);
              }, emailEditable),
              const SizedBox(height: 12),
              _buildEditableField("Phone Number", phoneController, () {
                setState(() => phoneEditable = !phoneEditable);
              }, phoneEditable),
              const SizedBox(height: 12),
              _buildDateField("Date of Birth", dobController),
              const SizedBox(height: 12),
              _buildStaticField("ID Type", id_type),
              const SizedBox(height: 12),
              _buildStaticField("ID Number", user_id),
              const SizedBox(height: 12),
              _buildTextField(emergencyContactController, "Emergency Contact"),
              const SizedBox(height: 12),
              _buildDropdownField(),
              const SizedBox(height: 20),
              if (hasChanges)
                ElevatedButton(
                  onPressed: _saveUserData,
                  child: const Text("Save Changes",
                      style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      VoidCallback toggleEdit, bool editable) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: editable,
            onChanged: (_) => setState(() => hasChanges = true),
            decoration: InputDecoration(
              labelText: label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              filled: true,
              fillColor: Colors.white,
            ),
            style: TextStyle(fontSize: 18),
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.grey),
          onPressed: toggleEdit,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              filled: true,
              fillColor: Colors.white,
            ),
            style: TextStyle(fontSize: 18),
            onTap: _pickDate,
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit_calendar, color: Colors.grey),
          onPressed: _pickDate,
        ),
      ],
    );
  }

  Widget _buildStaticField(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal),
      ),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
          children: [
            TextSpan(
                text: value, style: TextStyle(fontWeight: FontWeight.normal))
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() => hasChanges = true),
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedSickness,
      onChanged: (value) => setState(() {
        selectedSickness = value;
        hasChanges = true;
      }),
      items: sicknessOptions
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      decoration: InputDecoration(
        labelText: "Health Condition",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      dropdownColor: Colors.white,
      style: TextStyle(fontSize: 18, color: Colors.black),
    );
  }
}
