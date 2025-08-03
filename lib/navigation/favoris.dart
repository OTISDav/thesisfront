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

  Future<void> _loadFavoris() async {
    try {
      final favorisList = await apiService.getFavoris();
      print("📌 Favoris reçus (brut) : $favorisList");

      List<Map<String, dynamic>> favorisDetails = [];

      for (var favori in favorisList) {
        int thesisId = favori["thesis"]; // Récupère l'ID de la thèse
        int favoriteId = favori["id"]; // Récupère l'ID du favori

        // 🔍 Obtenir les détails de la thèse associée
        Map<String, dynamic>? thesisDetails = await apiService.getThesisDetails(thesisId);

        if (thesisDetails != null) {
          thesisDetails['favorite_id'] = favoriteId; // Stocker l'ID du favori
          favorisDetails.add(thesisDetails);
        }
      }

      setState(() {
        favoris = favorisDetails; // Met à jour la liste avec les thèses complètes et l'ID du favori
        print("📌 Favoris disponibles (traités) : $favoris");
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
                            document['document'] ?? '',
                            document['summary'] ?? '',
                            document['id'] ?? 0,
                            document['favorite_id'] as int?, // Passer l'ID du favori
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
    int? favoriteId, // Accepter l'ID du favori
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
                    if (favoriteId != null) {
                      _handleRemoveFavorite(favoriteId); // Utiliser l'ID du favori
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: ID de favori non trouvé')),
                      );
                    }
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
    try {
      // Vérifie si l’URL se termine par ".pdf", sinon l’ajoute
      String fixedUrl = fileUrl;
      if (!fixedUrl.endsWith('.pdf')) {
        fixedUrl = '$fixedUrl.pdf';
      }

      await apiService.downloadPdfWithHttp(fixedUrl, "thesis_$thesisId");
    } catch (e) {
      throw Exception('Impossible de télécharger le fichier : $e');
    }
  }





  void _handleRemoveFavorite(int favoriteId) {
    print("🗑 Tentative de suppression du favori avec l'ID du favori : $favoriteId");

    apiService.removeFromFavorites(favoriteId).then((_) {
      setState(() {
        favoris.removeWhere((fav) => fav['favorite_id'] == favoriteId); // Supprimer par l'ID du favori
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