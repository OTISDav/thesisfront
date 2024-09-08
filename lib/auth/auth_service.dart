import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<String> loginWithEmail(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/accounts/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_or_email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['tokens']['access']);
      return data['tokens']['access'];
    } else {
      throw Exception('Information incorrecte');
    }
  }

  Future<String> loginWithUsername(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/accounts/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['tokens']['access']);
      return data['tokens']['access'];
    } else {
      throw Exception('Information incorrecte');
    }
  }

  Future<void> register(String username, String phone, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/accounts/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'phone_number': phone,
        'email': email,
        'password': password
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'enregistrement');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
