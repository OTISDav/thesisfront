import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  // Constructeur pour définir l'URL de base de l'API
  ApiService(this.baseUrl);

  // Sauvegarde le token JWT dans SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Récupère le token JWT
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 📌 Publier un document avec fichier obligatoire
  Future<void> publishDocument(Map<String, dynamic> documentData, {required File file}) async {
  final token = await _getToken();
  if (token == null) {
    print('❌ Erreur: Token non disponible.');
    return;
  }

  if (!file.existsSync()) {
    print("❌ Le fichier sélectionné n'existe pas !");
    return;
  }

  final url = Uri.parse('$baseUrl/api/theses/theses/');
  
  print('📤 Envoi du document à : $url');
  print('🔑 Token utilisé : $token');
  print('📂 Données envoyées : $documentData');
  print('📄 Fichier sélectionné : ${file.path}');

  try {
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = documentData['title']
      ..fields['author'] = documentData['author']
      ..fields['summary'] = documentData['summary']
      ..fields['field_of_study'] = documentData['field_of_study']
      ..fields['year'] = documentData['year'].toString()
      ..files.add(await http.MultipartFile.fromPath('document', file.path)); // Clé `document`

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    print('🔄 Réponse du serveur: ${response.statusCode}');
    print('💬 Message: ${responseData.body}');

    if (response.statusCode == 201) {
      print('✅ Thèse ajoutée avec succès');
    } else {
      print('❌ Erreur ajout thèse: ${responseData.body}');
    }
  } catch (e) {
    print('❌ Exception lors de l\'ajout du document: $e');
  }
}


  // 📌 Récupérer tous les documents
  Future<List<Map<String, dynamic>>> getDocuments() async {
    final token = await _getToken();
    if (token == null) return [];

    final url = Uri.parse('$baseUrl/api/theses/theses/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('❌ Erreur chargement documents: ${response.body}');
      return [];
    }
  }

  // 📌 Ajouter un document aux favoris
  // Future<void> addToFavorites(int thesisId) async {
  //   final token = await _getToken();
  //   if (token == null) return;

  //   final url = Uri.parse('$baseUrl/api/theses/favorites/');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
  //     body: jsonEncode({'thesis': thesisId}),
  //   );

  //   if (response.statusCode == 201) {
  //     print('✅ Document ajouté aux favoris');
  //   } else {
  //     print('❌ Erreur ajout favoris: ${response.body}');
  //   }
  // }
  
  Future<void> addToFavorites(Map<String, dynamic> body) async {
  final token = await _getToken();
  if (token == null) {
    print('🚨 Erreur: Token JWT manquant !');
    return;
  }

  final url = Uri.parse('$baseUrl/api/theses/favorites/');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body), // Envoi du bon format JSON
  );

  print('📤 Envoi favori : $body');
  print('🔄 Réponse du serveur : ${response.statusCode}');

  if (response.statusCode == 201) {
    print('✅ Thèse ajoutée aux favoris avec succès !');
  } else {
    print('❌ Erreur ajout favori : ${response.body}');
  }
}

// desactive favoris

Future<void> removeFromFavorites(int favoriteId) async {
  final token = await _getToken();
  if (token == null) return;

  final url = Uri.parse('$baseUrl/api/theses/favorites/$favoriteId/');
  print("🔗 URL DELETE : $url");

  final response = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 204) {
    print('✅ Favori supprimé avec succès');
  } else {
    print('❌ Erreur suppression favori: ${response.body}');
  }
}



//detail thesis

Future<Map<String, dynamic>?> getThesisDetails(int thesisId) async {
  final token = await _getToken();
  final url = Uri.parse('$baseUrl/api/theses/theses/$thesisId/');

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Erreur récupération thèse : ${response.body}');
      return null;
    }
  } catch (e) {
    print('❌ Erreur requête thèse : $e');
    return null;
  }
}


  // 📌 Récupérer la liste des annotations
  Future<List<Map<String, dynamic>>> getAnnotations() async {
    final token = await _getToken();
    if (token == null) return [];

    final url = Uri.parse('$baseUrl/api/theses/annotations/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('❌ Erreur récupération annotations: ${response.body}');
      return [];
    }
  }

// 📌 Récupérer la liste des favoris
Future<List<Map<String, dynamic>>> getFavoris() async {
  final token = await _getToken();
  if (token == null) return [];

  final url = Uri.parse('$baseUrl/api/theses/favorites/'); // Assurez-vous que l'URL est correcte pour les favoris
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  } else {
    print('❌ Erreur récupération favoris: ${response.body}');
    return [];
  }
}


  // 📌 Ajouter une annotation à un document
  Future<void> addAnnotation(int thesisId, String note) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/api/theses/annotations/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'thesis': thesisId, 'note': note}),
    );

    if (response.statusCode == 201) {
      print('✅ Annotation ajoutée');
    } else {
      print('❌ Erreur ajout annotation: ${response.body}');
    }
  }

  // 📌 Télécharger un document
  Future<void> registerDownload(int thesisId) async {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/api/theses/download/$thesisId/');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print('✅ Téléchargement enregistré');
    } else {
      print('❌ Erreur téléchargement: ${response.body}');
    }
  }

  // 📌 Récupérer le profil utilisateur
  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await _getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/api/users/profile/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Erreur profil utilisateur: ${response.body}');
      return null; // Retourne null en cas d'erreur
    }
  }

}
