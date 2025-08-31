import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour choisir une image
import '../auth/api_service.dart'; // Ton service API

class EditProfilePage extends StatefulWidget {
  final ApiService apiService;

  EditProfilePage({required this.apiService});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _imageFile;
  bool _isLoading = false;
  String? _message;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_imageFile == null) {
      setState(() {
        _message = "Veuillez choisir une image d'abord.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    bool success = await widget.apiService.updateProfilePicture(_imageFile!);

    setState(() {
      _isLoading = false;
      _message = success ? "Photo mise à jour avec succès !" : "Erreur lors de la mise à jour.";
      if (success) _imageFile = null; // reset image
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // colors: [
            //   Color.fromARGB(255, 15, 15, 15),
            //   Color.fromARGB(255, 44, 48, 49),
            //   Color.fromARGB(255, 15, 15, 15),
            // ],
            colors: [Color(0xFF2F6D78), Color(0xFFAAC4C4)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Modifier le profil'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _imageFile == null
                    ? CircleAvatar(
                        radius: 60,
                        backgroundColor: Color.fromARGB(255, 224, 241, 245),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Color.fromARGB(255, 224, 101, 101),
                        ),
                      )
                    : CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(_imageFile!),
                      ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo_library),
                  label: Text('Choisir une photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
                SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _uploadProfilePicture,
                        child: Text('Mettre à jour la photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                      ),
                if (_message != null) ...[
                  SizedBox(height: 20),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains("succès")
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
