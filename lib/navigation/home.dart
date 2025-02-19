import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/api_service.dart'; // Assurez-vous que le chemin d'importation est correct
import 'profil.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pdfFiles = [];
  List<Map<String, dynamic>> filteredPdfFiles = [];
  TextEditingController searchController = TextEditingController();

  ApiService apiService = ApiService('https://ubuntuthesisbackend.onrender.com'); // Remplacez par votre URL d'API

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final documents = await apiService.getDocuments();
      print('Documents reçus : $documents'); // Ajoutez cette ligne pour déboguer
      setState(() {
        pdfFiles = documents.map((doc) {
          return {
            'id': doc['id'] ?? 0,
            'title': doc['title'] ?? '',
            'file': doc['file'] ?? '',
            'sammary': doc['sammary'] ?? '',
            'summary': doc['summary'] ?? '',
          };
        }).toList();
        filteredPdfFiles = pdfFiles;
      });
    } catch (e) {
      print('Erreur lors du chargement des documents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des documents')),
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
              colors: [Color(0xFF00A8AA), Color(0xFF004D40)], // Dégradé du bleu clair au gris anthracite
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilPage()),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage('URL_DE_L_AVATAR'), // Remplacez par l'URL de l'avatar
                        radius: 20.0,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {
                        // Gérer l'événement de notification
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterList();
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPdfFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    var document = filteredPdfFiles[index];
                    return _buildPdfCard(
                      context,
                      document['title'] ?? '',
                      document['file'] ?? '',
                      document['summary'] ?? '',
                      document['id'] ?? 0, // Assurez-vous que documentId n'est jamais null
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

  void filterList() {
    setState(() {
      filteredPdfFiles = pdfFiles.where((pdf) {
        bool byName = (pdf['title'] ?? '').toLowerCase().contains(searchController.text.toLowerCase());
        return byName;
      }).toList();
    });
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
      color: Color(0xFF424242), // Couleur des cartes
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
                      await _handleDownload(fileUrl, documentId);  // Passez aussi le documentId ici
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors du téléchargement: $e')),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.redAccent),
                  onPressed: () {
                    _handleFavorite(documentId);
                  },
                ),
                SizedBox(height: 16),
                IconButton(
                  icon: Icon(Icons.note_add, color: Colors.orangeAccent),
                  onPressed: () {
                    _showAnnotationDialog(context, documentId);
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
      await apiService.registerDownload(thesisId);  // Utilisation de thesisId (int)
    } else {
      throw Exception('Impossible d\'ouvrir le fichier');
    }
  }

  // void _handleFavorite(int documentId) {
  //   print("ID du document : $documentId");  // Log la valeur du documentId

  //   if (documentId == null || documentId <= 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('ID de document invalide')),
  //     );
  //     return;
  //   }

  //   // Si addToFavorites attend un entier, passez simplement documentId
  //   apiService.addToFavorites(documentId).then((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Ajouté aux favoris')),
  //     );
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Erreur: $error')),
  //     );
  //   });
  // }

  void _handleFavorite(int documentId) {
  print("📌 ID du document avant envoi : $documentId");  // Debugging

  if (documentId == null || documentId <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚠️ ID de document invalide : $documentId')),
    );
    return;
  }

  // Préparer l'objet JSON attendu
  Map<String, dynamic> data = {"thesis": documentId};
  print("📤 Envoi aux favoris : $data");  // Vérifier la requête envoyée

  apiService.addToFavorites(data).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Ajouté aux favoris')),
    );
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Erreur ajout favoris : $error')),
    );
  });
}





  void _showAnnotationDialog(BuildContext context, int documentId) {
    TextEditingController annotationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF424242), // Couleur de fond du dialogue
          title: Text("Ajouter une annotation", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: annotationController,
            decoration: InputDecoration(
              hintText: "Entrez votre annotation ici",
              hintStyle: TextStyle(color: Colors.white70),
            ),
            maxLines: 3,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text("Annuler", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Ajouter", style: TextStyle(color: Colors.white)),
              onPressed: () {
                apiService.addAnnotation(documentId, annotationController.text).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Annotation ajoutée')),
                  );
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}
