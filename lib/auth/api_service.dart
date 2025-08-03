import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';

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

//desactive favoris

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

// 📌 Modifier une annotation
Future<void> updateAnnotation(int annotationId, String newNote, int thesisId) async {
  final token = await _getToken();
  if (token == null) return;

  final url = Uri.parse('$baseUrl/api/theses/annotations/$annotationId/');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'note': newNote, 'thesis': thesisId}), // Incluez thesisId ici
  );

  if (response.statusCode == 200) {
    print('✅ Annotation modifiée avec succès');
  } else {
    print('❌ Erreur modification annotation: ${response.body}');
  }
}

// 📌 Supprimer une annotation
Future<void> deleteAnnotation(int annotationId) async {
  final token = await _getToken();
  if (token == null) return;

  final url = Uri.parse('$baseUrl/api/theses/annotations/$annotationId/');
  final response = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 204) {
    print('✅ Annotation supprimée avec succès');
  } else {
    print('❌ Erreur suppression annotation: ${response.body}');
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
// telecharger document

Future<void> downloadPdfWithHttp(String url, String fileName) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final contentType = response.headers['content-type']; // ex: application/pdf
      String extension = '.pdf'; // Valeur par défaut

      if (contentType != null) {
        if (contentType.contains('pdf')) {
          extension = '.pdf';
        } else if (contentType.contains('msword')) {
          extension = '.doc';
        } else if (contentType.contains('officedocument.wordprocessingml.document')) {
          extension = '.docx';
        }
      }

      final bytes = response.bodyBytes;

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$fileName$extension");

      await file.writeAsBytes(bytes);
      print("✅ Fichier sauvegardé : ${file.path}");

      OpenFile.open(file.path); // Ouvre le fichier après téléchargement
    } else {
      print("❌ Erreur de téléchargement : ${response.statusCode}");
    }
  } catch (e) {
    print("🚫 Exception : $e");
  }
}



  // 📌 Récupérer le profil utilisateur
  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await _getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/api/users/auth/profile/');
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


    Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'errors': 'Token manquant'};
    }

    final url = Uri.parse('$baseUrl/api/users/auth/change-password/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_new_password': confirmNewPassword,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'errors': data,
      };
    }
  }


  
  /// Met à jour la photo de profil
  Future<bool> updateProfilePicture(File imageFile) async {
    final token = await _getToken();
    if (token == null) {
      print('❌ Token non disponible');
      return false;
    }

    final url = Uri.parse('$baseUrl/api/users/auth/profile/update/'); // adapte l’URL si besoin

    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture', // clé attendue par ton serializer Django
        imageFile.path,
        filename: basename(imageFile.path),
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('✅ Photo de profil mise à jour avec succès');
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print('❌ Erreur mise à jour photo: ${response.statusCode} $respStr');
        return false;
      }
    } catch (e) {
      print('🚫 Exception upload photo: $e');
      return false;
    }
  }


}


