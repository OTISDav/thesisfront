import 'package:flutter/material.dart';
import '../auth/api_service.dart';

const String baseUrl = 'https://ubuntuthesisbackend.onrender.com';

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

  // Variables pour toggle visibilité mots de passe
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiService = ApiService(baseUrl);

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
          SnackBar(
            content: Text('Mot de passe changé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = response['errors'].toString();
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, bool showPassword, VoidCallback toggleVisibility) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.teal, width: 2),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          showPassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey[600],
        ),
        onPressed: toggleVisibility,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: Colors.grey[100],
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Changer le mot de passe"),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 35),
              TextFormField(
                
                controller: _oldPasswordController,
                obscureText: !_showOldPassword,
                
                decoration: _buildInputDecoration(
                  "Ancien mot de passe",
                  _showOldPassword,
                  () => setState(() => _showOldPassword = !_showOldPassword),
                ),
                validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
              ),
              SizedBox(height: 35),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: _buildInputDecoration(
                  "Nouveau mot de passe",
                  _showNewPassword,
                  () => setState(() => _showNewPassword = !_showNewPassword),
                ),
                validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
              ),
              SizedBox(height: 35),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: _buildInputDecoration(
                  "Confirmer le nouveau mot de passe",
                  _showConfirmPassword,
                  () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Champ requis";
                  if (value != _newPasswordController.text) return "Les mots de passe ne correspondent pas";
                  return null;
                },
              ),
              SizedBox(height: 35),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Changer",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
