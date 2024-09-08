import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'annotation.dart';

class DashboardPage extends StatelessWidget {
  // Méthode pour récupérer les statistiques des documents (favoris, annotations, téléchargements)
  Future<Map<String, int>> fetchCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // Récupérez le jeton d'authentification

    final response = await http.get(
      Uri.parse('https://3b6d-2c0f-f0f8-845-4d01-8d48-23c8-845e-1071.ngrok-free.app/api/documents/counts/'),
      headers: {
        'Authorization': 'Bearer $token', // Ajoutez le jeton à l'en-tête
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return {
        'annotations': data['jaimes_count'] ?? 0,
        'telechargements': data['telechargements_count'] ?? 0,
      };
    } else {
      throw Exception('Erreur lors de la récupération des données');
    }
  }

  // Méthode pour récupérer les documents publiés par l'utilisateur
  Future<List<Map<String, dynamic>>> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // Récupérez le jeton d'authentification

    final response = await http.get(
      Uri.parse('https://3b6d-2c0f-f0f8-845-4d01-8d48-23c8-845e-1071.ngrok-free.app/api/documents/user/documents/'),
      headers: {
        'Authorization': 'Bearer $token', // Ajoutez le jeton à l'en-tête
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la récupération des documents');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 47, 109, 120),
        body: SafeArea(
          child: FutureBuilder<Map<String, int>>(
            future: fetchCounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              } else {
                final counts = snapshot.data ?? {};
          
                return ListView(
                  padding: EdgeInsets.all(16.0),
                  children: <Widget>[
                    SizedBox(height: 30),
                    // Affichage des sections statistiques
                    _buildSection(
                      title: 'Annotations',
                      icon: Icons.edit,
                      count: counts['annotations'] ?? 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AnnotationListPage()),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSection(
                      title: 'Téléchargements',
                      icon: Icons.cloud_download,
                      count: counts['telechargements'] ?? 0,
                      onTap: () {
                        // Action à effectuer lorsque vous appuyez sur le bouton Téléchargements
                        print('Téléchargements button tapped');
                        // Naviguer vers la page des téléchargements ou effectuer une action
                      },
                    ),
                    SizedBox(height: 16),
                    // Affichage des documents publiés
                    _buildPublishedDocuments(),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Widget pour créer une section avec un titre, une icône et un nombre
  Widget _buildSection({
    required String title,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: 48,
                color: Colors.blue,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour afficher les documents publiés par l'utilisateur
  Widget _buildPublishedDocuments() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getDocuments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else {
          final documents = snapshot.data ?? [];

          if (documents.isEmpty) {
            return Center(child: Text("Vous n'avez publié aucun document"));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos documents publiés',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true, // Important pour permettre le défilement
                  physics: NeverScrollableScrollPhysics(), // Empêcher le ListView de défiler
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return Card(
                      elevation: 4.0,
                      child: ListTile(
                        title: Text(document['title']),
                        subtitle: Text('Auteur: ${document['author']}'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Action à effectuer lors du tap sur un document
                          print('Document tapped');
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          }
        }
      },
    );
  }
}
