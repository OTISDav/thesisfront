import 'package:flutter/material.dart';
import 'loginpage.dart';
import './RegistrationPage.dart';

class ConnexionPage extends StatelessWidget {
  const ConnexionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 47, 109, 120),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Text(
                'THESIS',
                style: TextStyle(
                  fontSize: 50,
                  color: Color.fromRGBO(244, 245, 247, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // const SizedBox(height: 35),
            // const Center(
            //   child: Text(
            //     'Méthode de Connexion',
            //     style: TextStyle(
            //       fontSize: 20,
            //       color: Color.fromRGBO(244, 245, 247, 1),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPageEmail()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_right_alt, color: Color(0xff052555)),
                  const SizedBox(width: 10),
                  Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Color(0xff052555),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 35),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
              // children: [
                // IconButton(
                //   icon: Image.asset('assets/google.png'), // Assurez-vous que l'image est dans le dossier assets
                //   iconSize: 50,
                //   onPressed: () {
                //     // Logique de connexion avec Google
                //   },
                // ),
                // const SizedBox(width: 20),
                // IconButton(
                //   icon: Icon(Icons.phone_android, color: Colors.white),
                //   iconSize: 50,
                //   onPressed: () {
                //     // Logique de connexion avec téléphone
                //   },
                // ),
            //   ],
            // ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tu n\'as pas de compte ?',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(223, 227, 236, 1),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                  child: const Text(
                    'Clique ici',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 157, 170, 176),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                // const Text(
                //   '?',
                //   style: TextStyle(
                //     fontSize: 20,
                //     color: Color.fromRGBO(223, 227, 236, 1),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
