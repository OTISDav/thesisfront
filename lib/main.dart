import 'package:flutter/material.dart';
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
    final token = await apiService.getToken(); // Récupère le token
    return token != null && token.isNotEmpty;
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
            return MyHomePage(); // Déjà connecté
          } else {
            return Welcome(); // Pas connecté
          }
        },
      ),
    );
  }
}
