import 'package:flutter/material.dart';
import '../auth/api_service.dart';

class AnnotationListPage extends StatefulWidget {
  @override
  _AnnotationListPageState createState() => _AnnotationListPageState();
}

class _AnnotationListPageState extends State<AnnotationListPage> {
  List<Map<String, dynamic>> annotations = [];

  ApiService apiService = ApiService('https://86b9-2c0f-f0f8-816-5c00-307a-4893-16ef-cc9f.ngrok-free.app'); // Remplacez par l'URL de votre API

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
  }

  Future<void> _loadAnnotations() async {
    try {
      final annotationList = await apiService.getAnnotations();
      setState(() {
        annotations = annotationList;
      });
    } catch (e) {
      print('Erreur lors du chargement des annotations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des annotations')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste de vos annotations personnelles'),
      ),
      body: annotations.isEmpty
          ? Center(child: Text('Aucune annotation trouvée'))
          : ListView.builder(
              itemCount: annotations.length,
              itemBuilder: (BuildContext context, int index) {
                var annotation = annotations[index];
                return ListTile(
                  title: Text(annotation['title'] ?? 'Titre non disponible'),
                  subtitle: Text(annotation['content'] ?? 'Annotation non disponible'),
                  // trailing: Text(annotation['created_at'] ?? ''),
                );
              },
            ),
    );
  }
}
