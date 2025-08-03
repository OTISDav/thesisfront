import 'package:flutter/material.dart';
import '../auth/api_service.dart';

const String baseUrl = 'https://ubuntuthesisbackend.onrender.com'; // Mets ici ton URL d'API

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiService = ApiService(baseUrl);  // <-- Fournir baseUrl ici

      final response = await apiService.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mot de passe changé avec succès')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = response['errors'].toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Changer le mot de passe")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Ancien mot de passe"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Champ requis" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Nouveau mot de passe"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Champ requis" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    InputDecoration(labelText: "Confirmer le nouveau mot de passe"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Champ requis";
                  if (value != _newPasswordController.text)
                    return "Les mots de passe ne correspondent pas";
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Changer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
