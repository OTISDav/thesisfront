import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../auth/api_service.dart';

class FavorisPage extends StatefulWidget {
  @override
  _FavorisPageState createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  List<Map<String, dynamic>> favoris = [];
  ApiService apiService = ApiService('https://ubuntuthesisbackend.onrender.com');

  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  // Future<void> _loadFavoris() async {
  //   try {
  //     final favorisList = await apiService.getFavoris();
  //     print('📌 Favoris reçus : $favorisList');  // Debugging

  //     setState(() {
  //       favoris = favorisList.map((fav) {
  //         return {
  //           'id': fav['thesis']['id'] ?? 0,  // Récupérer l'ID du document favori
  //           'title': fav['thesis']['title'] ?? '',
  //           'file': fav['thesis']['document'] ?? '', // Vérifie que 'document' est la bonne clé
  //           'summary': fav['thesis']['summary'] ?? '',
  //         };
  //       }).toList();
  //     });
  //   } catch (e) {
  //     print('❌ Erreur chargement favoris: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Erreur lors du chargement des favoris')),
  //     );
  //   }
  // }

  Future<void> _loadFavoris() async {
  try {
    final favorisList = await apiService.getFavoris();
    print("📌 Favoris reçus : $favorisList");

    List<Map<String, dynamic>> favorisDetails = [];

    for (var favori in favorisList) {
      int thesisId = favori["thesis"]; // Récupère l'ID de la thèse

      // 🔍 Obtenir les détails de la thèse associée
      Map<String, dynamic>? thesisDetails = await apiService.getThesisDetails(thesisId);

      if (thesisDetails != null) {
        favorisDetails.add(thesisDetails);
      }
    }

    setState(() {
      favoris = favorisDetails; // Met à jour la liste avec les thèses complètes
    });
  } catch (e) {
    print('❌ Erreur chargement favoris: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors du chargement des favoris')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A8AA), Color(0xFF004D40)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '⭐ Documents en favoris',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: favoris.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun document favori',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: favoris.length,
                        itemBuilder: (BuildContext context, int index) {
                          var document = favoris[index];
                          return _buildPdfCard(
                            context,
                            document['title'] ?? '',
                            document['file'] ?? '',
                            document['summary'] ?? '',
                            document['id'] ?? 0,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfCard(
    BuildContext context,
    String title,
    String fileUrl,
    String resume,
    int documentId,
  ) {
    return Card(
      elevation: 6,
      color: Color(0xFF424242),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
                SizedBox(height: 8),
              ],
            ),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                title: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    resume,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.file_download, color: Colors.white70),
                  onPressed: () async {
                    try {
                      await _handleDownload(fileUrl, documentId);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors du téléchargement: $e')),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () {
                    _handleRemoveFavorite(documentId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDownload(String fileUrl, int thesisId) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
      await apiService.registerDownload(thesisId);
    } else {
      throw Exception('Impossible d\'ouvrir le fichier');
    }
  }

  // void _handleRemoveFavorite(int documentId) {
  //   print("🗑 Suppression du favori avec ID : $documentId");

  //   apiService.removeFromFavorites(documentId).then((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('🚮 Favori supprimé')),
  //     );
  //     _loadFavoris(); // Rafraîchir la liste des favoris
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('❌ Erreur suppression favoris: $error')),
  //     );
  //   });
  // }

  void _handleRemoveFavorite(int favoriteId) {
  print("📌 Favoris disponibles : $favoris");
  print("🗑 Suppression du favori avec ID : $favoriteId");

  if (favoriteId == null || favoriteId <= 0) {
    print("⚠️ Erreur : ID de favori invalide !");
    return;
  }

  apiService.removeFromFavorites(favoriteId).then((_) {
    setState(() {
      favoris.removeWhere((fav) => fav['id'] == favoriteId); // Mise à jour locale
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Favori supprimé')),
    );
  }).catchError((error) {
    print("❌ Erreur suppression favori: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Erreur suppression favori: $error')),
    );
  });
}

}
