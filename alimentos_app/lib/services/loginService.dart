import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl = "http://192.168.1.178:5002";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$apiUrl/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }
}
