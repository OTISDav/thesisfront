import 'package:flutter/material.dart';
import 'loginpage.dart';
import './RegistrationPage.dart';

class ConnexionPage extends StatelessWidget {
  const ConnexionPage({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonWidth = 300; // largeur fixe pour les 2 boutons

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 47, 109, 120),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Text(
                'THESE',
                style: TextStyle(
                  fontSize: 50,
                  color: Color.fromRGBO(244, 245, 247, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // const SizedBox(height: 250),


                SizedBox(height: 20), // espace entre le texte et l'image

    // Image locale depuis les assets
    Image.asset(
      'assets/3.png',
      width: 400,
      height: 400,
      fit: BoxFit.contain,
    ),

    SizedBox(height: 40),

            // Bouton Se connecter
            SizedBox(
              width: buttonWidth,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // fond blanc
                  foregroundColor: Color(0xff052555), // texte bleu foncé
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPageEmail()),
                  );
                },
                child: Text(
                  'Se connecter',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bouton Créer un compte
            SizedBox(
              width: buttonWidth,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff052555), // fond bleu foncé
                  foregroundColor: Colors.white, // texte blanc
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                child: Text(
                  'Créer un compte',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
