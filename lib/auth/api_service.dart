import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException([this.message = 'Token expiré']);
  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('✅ Token supprimé car expiré');
  }

  Future<void> publishDocument(Map<String, dynamic> documentData, {required File file}) async {
    final token = await getToken();
    if (token == null) {
      print('❌ Erreur: Token non disponible.');
      return;
    }

    if (!file.existsSync()) {
      print("❌ Le fichier sélectionné n'existe pas !");
      return;
    }

    final url = Uri.parse('$baseUrl/api/theses/theses/');
    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = documentData['title']
        ..fields['author'] = documentData['author']
        ..fields['summary'] = documentData['summary']
        ..fields['field_of_study'] = documentData['field_of_study']
        ..fields['year'] = documentData['year'].toString()
        ..files.add(await http.MultipartFile.fromPath('document', file.path));

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 401) {
        await _removeToken();
        throw TokenExpiredException();
      }

      print('🔄 Réponse du serveur: ${response.statusCode}');
      print('💬 Message: ${responseData.body}');

      if (response.statusCode == 201) {
        print('✅ Thèse ajoutée avec succès');
      } else {
        print('❌ Erreur ajout thèse: ${responseData.body}');
      }
    } catch (e) {
      if (e is TokenExpiredException) rethrow;
      print('❌ Exception lors de l\'ajout du document: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDocuments() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse('$baseUrl/api/theses/theses/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('❌ Erreur chargement documents: ${response.body}');
      return [];
    }
  }

  Future<void> addToFavorites(Map<String, dynamic> body) async {
    final token = await getToken();
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
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    print('📤 Envoi favori : $body');
    print('🔄 Réponse du serveur : ${response.statusCode}');

    if (response.statusCode == 201) {
      print('✅ Thèse ajoutée aux favoris avec succès !');
    } else {
      print('❌ Erreur ajout favori : ${response.body}');
    }
  }

  Future<void> removeFromFavorites(int favoriteId) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/api/theses/favorites/$favoriteId/');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 204) {
      print('✅ Favori supprimé avec succès');
    } else {
      print('❌ Erreur suppression favori: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> getThesisDetails(int thesisId) async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/api/theses/theses/$thesisId/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Erreur récupération thèse : ${response.body}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAnnotations() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse('$baseUrl/api/theses/annotations/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('❌ Erreur récupération annotations: ${response.body}');
      return [];
    }
  }

  Future<void> updateAnnotation(int annotationId, String newNote, int thesisId) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/api/theses/annotations/$annotationId/');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'note': newNote, 'thesis': thesisId}),
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }
    if (response.statusCode == 200) {
      print('✅ Annotation modifiée avec succès');
    } else {
      print('❌ Erreur modification annotation: ${response.body}');
    }
  }

  Future<void> deleteAnnotation(int annotationId) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/api/theses/annotations/$annotationId/');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 204) {
      print('✅ Annotation supprimée avec succès');
    } else {
      print('❌ Erreur suppression annotation: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getFavoris() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse('$baseUrl/api/theses/favorites/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('❌ Erreur récupération favoris: ${response.body}');
      return [];
    }
  }

  Future<void> addAnnotation(int thesisId, String note) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('$baseUrl/api/theses/annotations/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'thesis': thesisId, 'note': note}),
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 201) {
      print('✅ Annotation ajoutée');
    } else {
      print('❌ Erreur ajout annotation: ${response.body}');
    }
  }

  Future<void> downloadPdfWithHttp(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String extension = '.pdf'; 
        final contentType = response.headers['content-type'];
        if (contentType != null) {
          if (contentType.contains('pdf')) extension = '.pdf';
          else if (contentType.contains('msword')) extension = '.doc';
          else if (contentType.contains('officedocument.wordprocessingml.document')) extension = '.docx';
        }

        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/$fileName$extension");

        await file.writeAsBytes(bytes);
        print("✅ Fichier sauvegardé : ${file.path}");

        OpenFile.open(file.path);

      } else {
        print("❌ Erreur de téléchargement : ${response.statusCode}");
      }
    } catch (e) {
      print("🚫 Exception : $e");
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/api/users/auth/profile/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Erreur profil utilisateur: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final token = await getToken();
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

    if (response.statusCode == 401) {
      await _removeToken();
      throw TokenExpiredException();
    }

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

  Future<bool> updateProfilePicture(File imageFile) async {
    final token = await getToken();
    if (token == null) {
      print('❌ Token non disponible');
      return false;
    }

    final url = Uri.parse('$baseUrl/api/users/auth/profile/update/');

    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture',
        imageFile.path,
        filename: basename(imageFile.path),
      ),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 401) {
        await _removeToken();
        throw TokenExpiredException();
      }

      if (response.statusCode == 200) {
        print('✅ Photo de profil mise à jour avec succès');
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print('❌ Erreur mise à jour photo: ${response.statusCode} $respStr');
        return false;
      }
    } catch (e) {
      if (e is TokenExpiredException) rethrow;
      print('🚫 Exception upload photo: $e');
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/password_reset/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'envoi du lien de réinitialisation');
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/users/auth/login/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access'] ?? data['token'];
      if (token != null) {
        await _saveToken(token);
        print('✅ Login réussi, token sauvegardé');
        return true;
      }
    }

    print('❌ Échec login: ${response.body}');
    return false;
  }


  Future<bool> saveSearch(Map<String, dynamic> searchData) async {
  final token = await getToken();
  if (token == null) {
    print('🚨 Erreur: Token JWT manquant');
    return false;
  }

  final url = Uri.parse('$baseUrl/api/theses/saved-searches/'); // adapte ce chemin selon ton API

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(searchData),
  );

  if (response.statusCode == 201) {
    print('✅ Recherche sauvegardée avec succès');
    return true;
  } else {
    print('❌ Erreur sauvegarde recherche : ${response.body}');
    return false;
  }
}


Future<void> sendFcmTokenToBackend(String fcmToken) async {
  final token = await getToken();
  if (token == null) {
    print('❌ Erreur : Token JWT absent');
    return;
  }

  final url = Uri.parse('$baseUrl/api/notification/fcm-devices/');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'registration_id': fcmToken,
      'type': 'android', // ou 'ios' selon la plateforme
    }),
  );

  if (response.statusCode == 201) {
    print('✅ Token FCM enregistré avec succès');
  } else {
    print('❌ Échec enregistrement token FCM: ${response.statusCode} ${response.body}');
  }
}



}
