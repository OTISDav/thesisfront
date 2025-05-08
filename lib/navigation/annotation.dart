import 'package:flutter/material.dart';
import '../auth/api_service.dart'; // Assurez-vous que le chemin est correct

class AnnotationListPage extends StatefulWidget {
  @override
  _AnnotationListPageState createState() => _AnnotationListPageState();
}

class _AnnotationListPageState extends State<AnnotationListPage> {
  List<Map<String, dynamic>> annotations = [];
  ApiService apiService = ApiService('https://ubuntuthesisbackend.onrender.com'); // Remplacez par votre API si nécessaire

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
  }

  Future<void> _loadAnnotations() async {
    try {
      final annotationList = await apiService.getAnnotations();
      print("📌 Annotations reçues : $annotationList"); // Debug
      setState(() {
        annotations = annotationList;
      });
    } catch (e) {
      print('❌ Erreur chargement annotations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des annotations')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 47, 109, 120),
        appBar: AppBar(
          title: Text('Vos annotations', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: annotations.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune annotation trouvée',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: annotations.length,
                      itemBuilder: (BuildContext context, int index) {
                        var annotation = annotations[index];
                        return _buildAnnotationCard(context, annotation);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationCard(BuildContext context, Map<String, dynamic> annotation) {
    dynamic thesisInfo = annotation['thesis'];
    String thesisTitle = '';
    int? thesisId; // Déclarez thesisId ici

    if (thesisInfo is Map && thesisInfo.containsKey('title')) {
      thesisTitle = thesisInfo['title'] as String;
      thesisId = thesisInfo['id'] as int?; // Essayez de récupérer l'ID de la thèse si c'est une map
    } else if (thesisInfo is int) {
      thesisTitle = 'ID de la thèse: $thesisInfo';
      thesisId = thesisInfo; // Si thesisInfo est un int, c'est l'ID
      // Vous pourriez faire une autre requête ici pour obtenir le titre complet si nécessaire
    } else {
      thesisTitle = 'Information sur la thèse non disponible';
    }

    String note = annotation['note'] ?? 'Aucune note';
    int annotationId = annotation['id'] as int? ?? -1; // Gestion du cas où l'ID est null

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
            leading: Icon(Icons.note, size: 48, color: Colors.orange),
            title: Text(
              thesisTitle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                note,
                style: TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    if (annotationId != -1 && thesisId != null) {
                      _showEditAnnotationDialog(context, annotationId, note, thesisId); // Passez thesisId
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Informations de l\'annotation ou de la thèse manquantes')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    if (annotationId != -1) {
                      _handleDeleteAnnotation(annotationId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ID d\'annotation invalide')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAnnotationDialog(BuildContext context, int annotationId, String currentNote, int thesisId) {
    TextEditingController annotationController = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modifier l'annotation"),
          content: TextField(
            controller: annotationController,
            decoration: InputDecoration(hintText: "Entrez votre annotation"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Modifier"),
              onPressed: () {
                _updateAnnotation(annotationId, annotationController.text, thesisId); // Passez thesisId
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateAnnotation(int annotationId, String newNote, int thesisId) { // Ajout de thesisId
    apiService.updateAnnotation(annotationId, newNote, thesisId).then((_) { // Passage de thesisId
      setState(() {
        int index = annotations.indexWhere((anno) => anno['id'] == annotationId);
        if (index != -1) {
          annotations[index]['note'] = newNote;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Annotation modifiée')),
      );
    }).catchError((error) {
      print("❌ Erreur modification annotation: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur modification annotation: $error')),
      );
    });
  }

  void _handleDeleteAnnotation(int annotationId) {
    apiService.deleteAnnotation(annotationId).then((_) {
      setState(() {
        annotations.removeWhere((anno) => anno['id'] == annotationId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑 Annotation supprimée')),
      );
    }).catchError((error) {
      print("❌ Erreur suppression annotation: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur suppression annotation: $error')),
      );
    });
  }
}