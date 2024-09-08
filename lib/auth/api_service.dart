import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  // Constructeur pour définir l'URL de base de l'API
  ApiService(this.baseUrl);

  // Méthode pour sauvegarder le token d'authentification dans SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Méthode pour récupérer le token d'authentification depuis SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Méthode pour envoyer des requêtes POST, avec la possibilité de télécharger un fichier
  Future<http.Response> post(String endpoint, Map<String, dynamic> data, {File? file}) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl$endpoint');

    if (file != null) {
      // Si un fichier est fourni, utiliser MultipartRequest pour gérer le téléchargement de fichier
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = data['title']
        ..fields['filiere'] = data['filiere']
        ..fields['annee'] = data['annee'].toString()
        ..fields['document_type'] = data['document_type']
        ..fields['resume'] = data['resume']
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      return await http.Response.fromStream(response);
    } else {
      // Si aucun fichier n'est fourni, envoyer une requête POST classique
      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
    }
  }

  // Méthode pour récupérer la liste des documents publiés par l'utilisateur
  Future<List<Map<String, dynamic>>> getDocuments() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/documents/memoire/list/');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erreur lors du chargement des documents: $e');
      rethrow;
    }
  }

  // Méthode pour récupérer la liste des favoris de l'utilisateur
  Future<List<Map<String, dynamic>>> getFavoris() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/documents/favoris/list/');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erreur lors du chargement des documents: $e');
      rethrow;
    }
  }

  // Méthode pour ajouter un document aux favoris de l'utilisateur
Future<void> addToFavorites(int documentId) async {
  final token = await _getToken();  // Obtenez le token le plus récent
  final url = Uri.parse('$baseUrl/api/documents/favoris/ajout/');
  print('ID du document envoyé : $documentId');  // Vérifiez l'ID
  final response = await http.post(
    url,
    body: jsonEncode({'document_id': documentId}),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('Favori ajouté avec succès');
  } else {
    print('Erreur lors de l\'ajout aux favoris: ${response.body}');
  }
}






  // Méthode pour récupérer la liste des annotations de l'utilisateur
  Future<List<Map<String, dynamic>>> getAnnotations() async {
    final token = await _getToken(); // Récupère le jeton d'authentification
    final url = Uri.parse('$baseUrl/api/documents/annotation/list/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Ajoutez le jeton à l'en-tête
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la récupération des annotations');
    }
  }

  // Méthode pour ajouter une annotation à un document
  Future<void> addAnnotation(int documentId, String annotation) async {
    final url = Uri.parse('$baseUrl/api/documents/annotation/add/');
  
    final response = await http.post(
      url,
      body: jsonEncode({
        'document_id': documentId.toString(),
        'annotation': annotation,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout de l\'annotation');
    }
  }

  // Méthode pour enregistrer un téléchargement de document
  Future<void> registerDownload(String fileUrl) async {
    final url = Uri.parse('$baseUrl/api/memoire/download/<int:pk>/');
    final response = await http.post(
      url,
      body: jsonEncode({'file_url': fileUrl}),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${await _getToken()}'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'enregistrement du téléchargement');
    }
  }

  // Méthode pour récupérer les statistiques de l'utilisateur (nombre de favoris, likes, etc.)
  Future<void> fetchDocumentCounts() async {
    final url = Uri.parse('$baseUrl/api/documents/counts/');
  
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Mettre à jour l'état de votre application avec les nouvelles données
    } else {
      throw Exception('Erreur lors de la récupération des données');
    }
  }

  // Méthode pour récupérer le profil de l'utilisateur
  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/api/accounts/profile/');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
