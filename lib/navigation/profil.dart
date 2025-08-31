import 'package:flutter/material.dart';
import '../connexion/sign_login.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/api_service.dart';
import '../navigation/change_password_page.dart';
import '../navigation/EditProfilePage.dart';

class ProfilPage extends StatelessWidget {
  final ApiService apiService = ApiService('https://ubuntuthesisbackend.onrender.com');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // colors: [
            //   Color.fromARGB(255, 15, 15, 15),
            //   Color.fromARGB(255, 44, 48, 49),
            //   Color.fromARGB(255, 15, 15, 15),
            // ],
            colors: [Color(0xFF2F6D78), Color(0xFFAAC4C4)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: FutureBuilder<Map<String, dynamic>?>(
            future: apiService.getUserProfile(),
            builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur lors de la récupération des informations de profil'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('Aucune donnée disponible'));
              } else {
                final user = snapshot.data!;
                final rawProfileImage = user['profile_picture'] ?? '';
                final profileImageUrl = rawProfileImage.isNotEmpty
                    ? 'https://res.cloudinary.com/dkk95mjgt/$rawProfileImage'
                    : 'https://example.com/default_profile_image.png';

                final userName = user['username'] ?? 'Nom non disponible';
                final userEmail = user['email'] ?? 'Email non disponible';

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(profileImageUrl),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        userName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        userEmail,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(color: Colors.white24),
                    SizedBox(height: 24),
                    ListTile(
                      leading: Icon(Icons.edit, color: Colors.white),
                      title: Text('Modifier le profil', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(apiService: apiService),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.lock, color: Colors.white),
                      title: Text('Changer le mot de passe', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications, color: Colors.white),
                      title: Text('Notifications', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        // À compléter
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.white),
                      title: Text('Déconnexion', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
