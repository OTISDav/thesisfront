import 'package:flutter/material.dart';
import '../connexion/sign_login.dart'; // Assurez-vous que ce fichier existe et contient la classe ConnexionPage

// Définition de la classe Welcome qui étend StatelessWidget
class welcome extends StatelessWidget {
  const welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 47, 109, 120),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Bienvenue sur THESIS',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromRGBO(244, 245, 247, 1),
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de connexion lors de l'appui sur le bouton
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnexionPage()),
                );
              },
              child: const  Text(
                  "Let's Go",
                style: TextStyle(
                   fontWeight: FontWeight.bold,
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
