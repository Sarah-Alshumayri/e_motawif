import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static const String serverUrl = "http://10.0.2.2/e_motawif_new";

  Future<String> reportItem(
    String itemName,
    String description,
    String location,
    String date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id") ?? ""; // ✅ Retrieve saved user ID

    final response = await http.post(
      Uri.parse("$serverUrl/lost_found_ai.php"),
      body: {
        "action": "report",
        "user_id": userId,
        "itemName": itemName,
        "description": description,
        "location": location,
        "date": date,
      },
    );

    final jsonResponse = jsonDecode(response.body);
    return jsonResponse["message"];
  }

  // ✅ AI-Based Lost Item Search
  Future<List<Map<String, dynamic>>> searchLostItem(
    String itemName,
    String description,
    String location,
    String date,
  ) async {
    final response = await http.post(
      Uri.parse("$serverUrl/lost_found_ai.php"),
      body: {
        "action": "search",
        "itemName": itemName,
        "description": description,
        "location": location,
        "date": date,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse["status"] == "success") {
        return List<Map<String, dynamic>>.from(jsonResponse["results"]);
      } else {
        throw Exception(jsonResponse["message"]);
      }
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }

  // ✅ Generic POST Method
  static Future<dynamic> postData({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/$url"),
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Server error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in postData(): $e");
      return null;
    }
  }

  // 🔐 Login
  Future<Map<String, dynamic>> login(String userId, String password) async {
    try {
      var response = await http.post(
        Uri.parse("$serverUrl/login.php"),
        body: {"user_id": userId, "password": password},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse["status"] == "success") {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("user_id", jsonResponse["user_id"]);
          await prefs.setString(
              "user_name", jsonResponse["name"]); // ✅ Save name here
        }

        return jsonResponse;
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

  // 🧑 Get User Profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      var response = await http.post(
        Uri.parse("$serverUrl/get_user_profile.php"),
        body: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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

  // 🧑‍💻 Save Profile
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

  // 📋 Tasks & Movement Handling (unchanged)
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
        }
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
    return [];
  }

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

  // ✅ Get Assigned Pilgrims for a Motawif
  static Future<Map<String, dynamic>> getAssignedPilgrims(
      String motawifId) async {
    final url = Uri.parse(
        "http://10.0.2.2/e_motawif_new/get_pilgrims_for_tracking.php");

    final response = await http.post(
      url,
      body: {
        'motawif_id': motawifId,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load assigned pilgrims');
    }
  }

  //get Admin Stats
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/get_admin_stats.php"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Failed to connect: $e",
      };
    }
  }

  static Future<void> saveMovement({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    print("📡 Saving movement: user=$userId lat=$latitude lng=$longitude");
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/save_movement.php"),
        body: {
          'user_id': userId,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );
      print("📬 Response: ${response.statusCode} ${response.body}");
    } catch (e) {
      print("❌ ERROR: $e");
    }
  }

  //get Pilgrim Distribution
  Future<List<Map<String, dynamic>>> getPilgrimDistribution() async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/get_pilgrim_distribution.php"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return List<Map<String, dynamic>>.from(json['data']);
        }
      }
    } catch (e) {
      print("Error fetching distribution: $e");
    }
    return [];
  }

// get Motawifs function for Admin dashboard
  Future<List<Map<String, dynamic>>> getMotawifs() async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/get_motawifs.php"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return List<Map<String, dynamic>>.from(json['data']);
        }
      }
    } catch (e) {
      print("Error fetching motawifs: $e");
    }
    return [];
  }

  // get Pilgrims for Admi dashboard
  Future<List<Map<String, dynamic>>> getPilgrims() async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/get_pilgrims.php"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return List<Map<String, dynamic>>.from(json['data']);
        }
      }
    } catch (e) {
      print("Error fetching pilgrims: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> assignPilgrimsToMotawif(
      String motawifId, List<String> pilgrimUserIds) async {
    final url = Uri.parse("$serverUrl/assign_pilgrims_bulk.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "motawif_id": motawifId,
          "pilgrim_ids": pilgrimUserIds,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
          "details": []
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection failed: $e",
        "details": []
      };
    }
  }

  // Fetch list of all Motawifs (for dropdown)
  // ✅ Fetch list of all Motawifs
  Future<List<Map<String, dynamic>>> getMotawifList() async {
    final response = await postData(url: 'get_motawifs.php', body: {});
    if (response != null &&
        response['status'] == 'success' &&
        response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      return [];
    }
  }

// ✅ Fetch list of all unassigned Pilgrims
  Future<List<Map<String, dynamic>>> getUnassignedPilgrims() async {
    final response =
        await postData(url: 'get_unassigned_pilgrims.php', body: {});
    if (response != null &&
        response['status'] == 'success' &&
        response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      return [];
    }
  }

// unassign Pilgrim for admin board
  Future<Map<String, dynamic>> unassignPilgrim(String pilgrimUserId) async {
    final url = Uri.parse("$serverUrl/unassign_pilgrim.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pilgrim_user_id": pilgrimUserId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Connection failed: $e"};
    }
  }
}
