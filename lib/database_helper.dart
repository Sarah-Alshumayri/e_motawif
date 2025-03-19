import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static const String serverUrl =
      "http://172.20.10.3/e_motawif_new"; // Update with actual server

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

  searchLostItem(String searchItem) {}

  reportItem(String s, String itemName, String description, String location,
      String status) {}
}
