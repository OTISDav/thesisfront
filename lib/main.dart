import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart'; // Ajouter cette dépendance dans pubspec.yaml
import 'navigation/welcomepage.dart';
import 'auth/api_service.dart';
import 'navigation/navigation.dart'; // Ta page d'accueil après login

void main() {
  final apiService = ApiService('https://ubuntuthesisbackend.onrender.com');
  runApp(MyApp(apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  MyApp(this.apiService);

  Future<bool> _isLoggedIn() async {
    final token = await apiService.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      // Vérifie si le token JWT est expiré
      return !Jwt.isExpired(token);
    } catch (e) {
      // En cas d'erreur de décodage on considère le token invalide
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thesis App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return MyHomePage(); // Déjà connecté avec token valide
          } else {
            return Welcome(); // Pas connecté ou token expiré
          }
        },
      ),
    );
  }
}
