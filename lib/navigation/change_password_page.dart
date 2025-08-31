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

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiService = ApiService(baseUrl);

      try {
        final response = await apiService.changePassword(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmNewPassword: _confirmPasswordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (response != null && response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mot de passe changé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = response?['errors']?.toString() ?? 'Erreur inconnue';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur réseau ou serveur: $e';
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, bool showPassword, VoidCallback toggleVisibility) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.teal, width: 2),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          showPassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.white70,
        ),
        onPressed: toggleVisibility,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.black.withOpacity(0.1),
    );
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
            title: Text("Changer le mot de passe"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          
          body: Padding(
            
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 35),
                  if (_errorMessage != null)
                    Container(
                      
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w600),
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
                    style: TextStyle(color: Colors.white),
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
                    style: TextStyle(color: Colors.white),
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
                    style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }
}
