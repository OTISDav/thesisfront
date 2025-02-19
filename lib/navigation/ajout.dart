import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../auth/api_service.dart';

class AddDocumentPage extends StatefulWidget {
  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final ApiService _apiService = ApiService('https://ubuntuthesisbackend.onrender.com');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;

  // 📌 Sélectionner un fichier PDF ou DOCX
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // 📌 Envoyer le document
  Future<void> _uploadDocument() async {
    if (_titleController.text.isEmpty ||
        _authorController.text.isEmpty ||
        _summaryController.text.isEmpty ||
        _fieldController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _selectedFile == null) {
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
        "title": _titleController.text,
        "author": _authorController.text,
        "summary": _summaryController.text,
        "field_of_study": _fieldController.text,
        "year": int.parse(_yearController.text),
      };

      await _apiService.publishDocument(data, file: _selectedFile!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document ajouté avec succès')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'ajout du document: $e';
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
              SizedBox(height: 40),
              _buildTextField(_titleController, "Titre"),
              SizedBox(height: 8),
              _buildTextField(_authorController, "Auteur"),
              SizedBox(height: 8),
              _buildTextField(_summaryController, "Résumé", maxLines: 3),
              SizedBox(height: 8),
              _buildTextField(_fieldController, "Filière"),
              SizedBox(height: 8),
              _buildTextField(_yearController, "Année", keyboardType: TextInputType.number),
              SizedBox(height: 20),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text("Sélectionner un fichier"),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFile != null ? "Fichier: ${_selectedFile!.path.split('/').last}" : "Aucun fichier sélectionné",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _uploadDocument,
                child: _isLoading ? CircularProgressIndicator() : Text("Ajouter"),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
