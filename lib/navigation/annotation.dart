import 'package:flutter/material.dart';
import '../auth/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnotationListPage extends StatefulWidget {
  @override
  _AnnotationListPageState createState() => _AnnotationListPageState();
}

class _AnnotationListPageState extends State<AnnotationListPage> {
  List<Map<String, dynamic>> annotationsWithThesisDetails = [];
  ApiService apiService = ApiService('https://ubuntuthesisbackend.onrender.com');

  @override
  void initState() {
    super.initState();
    _loadAnnotationsWithThesisDetails();
  }

  Future<void> _loadAnnotationsWithThesisDetails() async {
    try {
      final annotationList = await apiService.getAnnotations();
      print("📌 Annotations reçues (brut) : $annotationList");

      List<Map<String, dynamic>> detailedAnnotations = [];
      for (var annotation in annotationList) {
        int thesisId = annotation['thesis'];
        try {
          Map<String, dynamic>? thesisDetails = await apiService.getThesisDetails(thesisId);
          if (thesisDetails != null) {
            detailedAnnotations.add({...annotation, 'thesis_details': thesisDetails});
          } else {
            print('⚠️ Détails de la thèse non trouvés pour l\'ID: $thesisId');
            detailedAnnotations.add(annotation);
          }
        } catch (e) {
          print('❌ Erreur lors de la récupération des détails de la thèse $thesisId: $e');
          detailedAnnotations.add(annotation);
        }
      }

      setState(() {
        annotationsWithThesisDetails = detailedAnnotations;
        print("📌 Annotations avec détails de la thèse : $annotationsWithThesisDetails");
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
        backgroundColor: Color.fromARGB(255, 11, 12, 12),
        // appBar: AppBar(
        //   title: Text('Vos annotations', style: TextStyle(color: Colors.white)),
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   iconTheme: IconThemeData(color: const Color.fromARGB(255, 199, 83, 83)),
        // ),
        body: Column(
          
          children: [
                          Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Vos Annotations ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: annotationsWithThesisDetails.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune annotation trouvée',
                        style: TextStyle(color: const Color.fromARGB(255, 15, 14, 14)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: annotationsWithThesisDetails.length,
                      itemBuilder: (BuildContext context, int index) {
                        var annotationWithDetails = annotationsWithThesisDetails[index];
                        return _buildAnnotationCard(context, annotationWithDetails);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationCard(BuildContext context, Map<String, dynamic> annotationWithDetails) {
    dynamic thesisDetails = annotationWithDetails['thesis_details'];
    String thesisTitle = '';
    String? documentUrl;
    int annotationId = annotationWithDetails['id'] as int? ?? -1;
    String note = annotationWithDetails['note'] ?? 'Aucune note';
    int? thesisId = annotationWithDetails['thesis'] as int?;

    if (thesisDetails is Map) {
      thesisTitle = thesisDetails['title'] as String? ?? 'Titre non disponible';
      documentUrl = thesisDetails['document'];

      if (documentUrl != null && !documentUrl.endsWith('.pdf')) {
        documentUrl = '$documentUrl.pdf';
      }


      thesisId = thesisDetails['id'] as int?;
    } else {
      thesisTitle = 'Information sur la thèse non disponible';
    }

    return Card(
      elevation: 10,
      color: Color.fromARGB(255, 210, 204, 204),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Icon(Icons.note, size: 48, color: const Color.fromARGB(255, 165, 158, 149)),
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
                if (documentUrl != null && documentUrl.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.file_download, color: Colors.green),
                    onPressed: () async {
                      if (await canLaunch(documentUrl!)) {
                        await apiService.downloadPdfWithHttp(documentUrl!, "thesis_$thesisId");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Impossible d\'ouvrir le fichier')),
                        );
                      }
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    if (annotationId != -1 && thesisId != null) {
                      _showEditAnnotationDialog(context, annotationId, note, thesisId);
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
                _updateAnnotation(annotationId, annotationController.text, thesisId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateAnnotation(int annotationId, String newNote, int thesisId) {
    apiService.updateAnnotation(annotationId, newNote, thesisId).then((_) {
      setState(() {
        int index = annotationsWithThesisDetails.indexWhere((anno) => anno['id'] == annotationId);
        if (index != -1) {
          annotationsWithThesisDetails[index]['note'] = newNote;
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
        annotationsWithThesisDetails.removeWhere((anno) => anno['id'] == annotationId);
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