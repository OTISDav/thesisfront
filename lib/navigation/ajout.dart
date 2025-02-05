import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../auth/api_service.dart';

class AddDocumentPage extends StatefulWidget {
  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final ApiService _apiService = ApiService('https://86b9-2c0f-f0f8-816-5c00-307a-4893-16ef-cc9f.ngrok-free.app');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _filiereController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  File? _file;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedType = 'memoire'; // Valeur par défaut

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    } else {
      setState(() {
        _file = null;
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (_titleController.text.isEmpty ||
        _filiereController.text.isEmpty ||
        _anneeController.text.isEmpty ||
        _resumeController.text.isEmpty ||
        _file == null) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs et sélectionner un fichier.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = {
        'title': _titleController.text,
        'annee': int.parse(_anneeController.text), // Convertir en entier
        'filiere': _filiereController.text,
        'resume': _resumeController.text,
        'document_type': _selectedType, // Utiliser la valeur sélectionnée
      };

      final response = await _apiService.post('/api/documents/memoire/create/', data, file: _file);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document ajouté avec succès')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'ajout du document. Statut: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'ajout du document : $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 47, 109, 120),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _filiereController,
                decoration: InputDecoration(labelText: 'Filière'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _anneeController,
                decoration: InputDecoration(labelText: 'Année'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: [
                  DropdownMenuItem(
                    value: 'memoire',
                    child: Text('Mémoire'),
                  ),
                  DropdownMenuItem(
                    value: 'these',
                    child: Text('Thèse'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _resumeController,
                decoration: InputDecoration(labelText: 'Résumé'),
                maxLines: 3,
              ),
              SizedBox(height: 35),
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _selectFile,
                    child: Text('Sélectionner un fichier'),
                  ),
                  SizedBox(width: 10),
                  Text(_file != null ? 'Fichier sélectionné: ${_file!.path.split('/').last}' : 'Aucun fichier sélectionné'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadDocument,
                child: _isLoading ? CircularProgressIndicator() : Text('Ajouter'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
