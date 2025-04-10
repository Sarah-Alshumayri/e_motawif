import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static const String serverUrl = "http://192.168.56.1/e_motawif_new";

  // ✅ Login
  Future<Map<String, dynamic>> login(String userId, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$serverUrl/login.php"),
        body: {"user_id": userId, "password": password},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        } else {
          return {
            "status": "error",
            "message": "Invalid server response format"
          };
        }
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Connection failed: $e"};
    }
  }

  // ✅ Get User Profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      var response = await http.post(
        Uri.parse("$serverUrl/get_user_profile.php"),
        body: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Failed to connect: $e"};
    }
  }

  // ✅ Save Updated User Profile
  Future<Map<String, dynamic>> saveUserProfile(
      Map<String, dynamic> data) async {
    try {
      var response = await http.post(
        Uri.parse("$serverUrl/update_user_profile.php"),
        body: data,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect: $e"};
    }
  }

  // ✅ Get All Tasks by motawif_id
  Future<List<Map<String, dynamic>>> getTasks(String motawifId) async {
    try {
      final response = await http.get(
        Uri.parse("$serverUrl/get_tasks.php?motawif_id=$motawifId"),
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return List<Map<String, dynamic>>.from(json['tasks']);
        } else {
          print("Server error: ${json['message']}");
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  // ✅ Save New or Update Task
  Future<Map<String, dynamic>> saveTask(Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/save_task.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(taskData),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect: $e"};
    }
  }

  // ✅ Delete Task by ID
  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/delete_task.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": taskId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect: $e"};
    }
  }

  // ✅ Save Movement History to DB
  static Future<void> saveMovement({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    print("📡 API CALL: userId=$userId, lat=$latitude, lng=$longitude");

    try {
      final response = await http.post(
        Uri.parse("$serverUrl/save_movement.php"),
        body: {
          'user_id': userId,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );

      print("📬 Status Code: ${response.statusCode}");
      print("📬 Response Body: ${response.body}");
    } catch (e) {
      print("❌ ERROR: $e");
    }
  }

  // Placeholder methods
  searchLostItem(String searchItem) {}

  reportItem(String userId, String itemName, String description,
      String location, String status) {}
}
