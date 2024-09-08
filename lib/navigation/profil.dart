import 'package:flutter/material.dart';
import '../connexion/sign_login.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/api_service.dart'; 

class ProfilPage extends StatelessWidget {
  final ApiService apiService = ApiService('https://3b6d-2c0f-f0f8-845-4d01-8d48-23c8-845e-1071.ngrok-free.app'); // Remplacez par votre URL d'API

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 47, 109, 120),
        body: FutureBuilder<Map<String, dynamic>>(
          future: apiService.getUserProfile(),
          builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur lors de la récupération des informations de profil'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('Aucune donnée disponible'));
            } else {
              final user = snapshot.data!;
              final profileImageUrl = user['profile_image'] ?? 'https://example.com/default_profile_image.png';
              final userName = user['username'] ?? 'Nom non disponible';
              final userEmail = user['email'] ?? 'Email non disponible';
      
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: CachedNetworkImageProvider(profileImageUrl),
                      // Si vous ne voulez pas utiliser de cache, utilisez :
                      // backgroundImage: NetworkImage(profileImageUrl),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      userName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      userEmail,
                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 253, 253, 253)),
                    ),
                  ),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 24),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Modifier le profil'),
                    textColor: Colors.white,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => EditProfilePage()),
                      // );
                    },
                  ),
                  SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Changer le mot de passe'),
                    textColor: Colors.white,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                      // );
                    },
                  ),
                  SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notifications'),
                    textColor: Colors.white,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => NotificationsPage()),
                      // );
                    },
                  ),
                  SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Déconnexion'),
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ConnexionPage()),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
