import 'package:flutter/material.dart';
import '../auth/api_service.dart'; // Assurez-vous que le chemin d'importation est correct

class FavorisPage extends StatefulWidget {
  @override
  _FavorisPageState createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  List<Map<String, dynamic>> favoris = [];
  ApiService apiService = ApiService('https://3b6d-2c0f-f0f8-845-4d01-8d48-23c8-845e-1071.ngrok-free.app'); // Remplacez par votre URL d'API

  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  Future<void> _loadFavoris() async {
    try {
      final favorisList = await apiService.getFavoris();
      setState(() {
        favoris = favorisList;
      });
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des favoris')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 47, 109, 120),
        body: Column(
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Documents mis en favoris',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: favoris.isEmpty
                  ? Center(child: Text('Aucun document favori', style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: favoris.length,
                      itemBuilder: (BuildContext context, int index) {
                        var document = favoris[index];
                        return _buildPdfCard(
                          context,
                          document['title'] ?? '',
                          document['file'] ?? '',
                          document['resume'] ?? '',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfCard(
    BuildContext context,
    String title,
    String fileUrl,
    String resume,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                resume,
                style: TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
