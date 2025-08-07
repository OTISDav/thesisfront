import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/api_service.dart';
import '../navigation/DocumentDetailPage.dart';
import 'profil.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pdfFiles = [];
  List<Map<String, dynamic>> filteredPdfFiles = [];
  TextEditingController searchController = TextEditingController();

  ApiService apiService = ApiService('https://ubuntuthesisbackend.onrender.com');

  String? profilePictureUrl;

  // Pour les filtres
  List<String> fieldsOfStudy = ['Tous'];
  List<String> years = ['Tous'];
  String selectedFieldOfStudy = 'Tous';
  String selectedYear = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadDocuments();
  }

  Future<void> _loadUserProfile() async {
    final profileData = await apiService.getUserProfile();
    if (profileData != null) {
      String? picPath = profileData['profile_picture'];
      if (picPath != null && picPath.isNotEmpty) {
        setState(() {
          profilePictureUrl = 'https://res.cloudinary.com/dkk95mjgt/$picPath';
        });
      }
    }
  }

  Future<void> _loadDocuments() async {
    try {
      final documents = await apiService.getDocuments();
      final favorisList = await apiService.getFavoris();

      Set<int> favorisIds = favorisList.map((fav) => fav['thesis'] as int).toSet();

      setState(() {
        pdfFiles = documents.map((doc) {
          return {
            'id': doc['id'] ?? 0,
            'title': doc['title'] ?? '',
            'file': doc['document'] != null && !doc['document'].endsWith('.pdf')
                ? '${doc['document']}.pdf'
                : doc['document'],
            'summary': doc['summary'] ?? '',
            'field_of_study': doc['field_of_study'] ?? '', // Assure-toi que ces champs existent dans ta réponse API
            'year': doc['year']?.toString() ?? '',
            'isFavorite': favorisIds.contains(doc['id']),
          };
        }).toList();

        filteredPdfFiles = pdfFiles;

        // Extraire les valeurs uniques pour les filtres
        _extractFilterOptions();
      });
    } catch (e) {
      print('Erreur lors du chargement des documents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des documents')),
      );
    }
  }

  void _extractFilterOptions() {
    final uniqueFields = pdfFiles
        .map((doc) => doc['field_of_study']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    uniqueFields.sort();

    final uniqueYears = pdfFiles
        .map((doc) => doc['year']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    uniqueYears.sort();

    setState(() {
      fieldsOfStudy = ['Tous', ...uniqueFields];
      years = ['Tous', ...uniqueYears];
    });
  }

  void filterList() {
    setState(() {
      filteredPdfFiles = pdfFiles.where((doc) {
        final titleMatch = (doc['title'] ?? '')
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

        final fieldMatch = selectedFieldOfStudy == 'Tous' ||
            (doc['field_of_study']?.toString() == selectedFieldOfStudy);

        final yearMatch =
            selectedYear == 'Tous' || (doc['year']?.toString() == selectedYear);

        return titleMatch && fieldMatch && yearMatch;
      }).toList();
    });
  }

  Future<void> _handleDownload(String fileUrl, int thesisId) async {
    try {
      await apiService.downloadPdfWithHttp(fileUrl, "thesis_$thesisId");
    } catch (e) {
      print('Erreur lors du téléchargement : $e');
    }
  }

  void _handleFavorite(int documentId) {
    if (documentId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ ID de document invalide : $documentId')),
      );
      return;
    }

    Map<String, dynamic> data = {"thesis": documentId};

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
          backgroundColor: Color(0xFF424242),
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
              onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filtrer par filière
          Expanded(
            child: DropdownButton<String>(
              value: selectedFieldOfStudy,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: TextStyle(color: Colors.white),
              underline: Container(height: 1, color: Colors.white),
              items: fieldsOfStudy.map((field) {
                return DropdownMenuItem<String>(
                  value: field,
                  // child: Text(field),
                  child: Text(field == 'Tous' ? 'Filière' : field),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFieldOfStudy = value!;
                  filterList();
                });
              },
            ),
          ),

          SizedBox(width: 16),

          // Filtrer par année
          Expanded(
            child: DropdownButton<String>(
              value: selectedYear,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: TextStyle(color: Colors.white),
              underline: Container(height: 1, color: Colors.white),
              items: years.map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  // child: Text(year),
                  child: Text(year == 'Tous' ? 'Année' : year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value!;
                  filterList();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(
    BuildContext context,
    String title,
    String fileUrl,
    String resume,
    int documentId,
    bool isFavorite,
  ) {
    return GestureDetector(
      child: Card(
        elevation: 6,
        color: Color.fromARGB(255, 210, 204, 204),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      resume,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        child: Text("Voir plus", style: TextStyle(color: Colors.blueAccent)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentDetailPage(
                                title: title,
                                summary: resume,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 12),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.file_download, color: Colors.white70),
                            onPressed: () => _handleDownload(fileUrl, documentId),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              _handleFavorite(documentId);
                              setState(() {
                                pdfFiles = pdfFiles.map((doc) {
                                  if (doc['id'] == documentId) {
                                    return {...doc, 'isFavorite': !isFavorite};
                                  }
                                  return doc;
                                }).toList();
                                filteredPdfFiles = filteredPdfFiles.map((doc) {
                                  if (doc['id'] == documentId) {
                                    return {...doc, 'isFavorite': !isFavorite};
                                  }
                                  return doc;
                                }).toList();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.note_add, color: Colors.orangeAccent),
                            onPressed: () => _showAnnotationDialog(context, documentId),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
              Color(0xFF2F6D78),
              Color(0xFFAAC4C4)
              ],
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
                        radius: 20.0,
                        backgroundImage: profilePictureUrl != null
                            ? NetworkImage(profilePictureUrl!)
                            : NetworkImage('https://via.placeholder.com/150'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
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
                  onChanged: (value) => filterList(),
                ),
              ),

              _buildFilters(),

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
                      document['id'] ?? 0,
                      document['isFavorite'] ?? false,
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
}
