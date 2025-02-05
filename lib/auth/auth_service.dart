import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  // 📌 **Connexion avec username**
  Future<String> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/users/auth/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Réponse du serveur: $data');  // Affiche la réponse pour inspection

      // Vérifie si les tokens sont présents dans la réponse
      if (data.containsKey('access') && data['access'] != null) {
        await _saveToken(data['access']);  // Sauvegarde du token d'accès
        return data['access'];  // Renvoie le token d'accès
      } else {
        throw Exception('Token d\'accès introuvable dans la réponse');
      }
    } else {
      // Gestion des erreurs, récupération du message détaillé si disponible
      final errorData = jsonDecode(response.body);
      print('Erreur API: $errorData');  // Affiche l'erreur complète
      throw Exception('Erreur de connexion: ${errorData['detail'] ?? 'Identifiants incorrects'}');
    }
  }

  // 📌 **Inscription**
  Future<void> register(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/users/auth/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password
      }),
    );

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      print('Erreur inscription: $errorData');
      throw Exception('Erreur lors de l\'inscription: ${errorData['detail'] ?? response.body}');
    }
  }

  // 📌 **Sauvegarde du token JWT**
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 📌 **Récupération du token**
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 📌 **Déconnexion**
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
