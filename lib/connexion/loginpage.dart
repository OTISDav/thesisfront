import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../navigation/navigation.dart';

class LoginPageEmail extends StatefulWidget {
  @override
  _LoginPageEmailState createState() => _LoginPageEmailState();
}

class _LoginPageEmailState extends State<LoginPageEmail> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService('https://ubuntuthesisbackend.onrender.com');
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.login(username, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs.';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 47, 109, 120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text('Connexion', style: TextStyle(fontSize: 40, color: Colors.white)),
              ),
              SizedBox(height: 100.0),
              _buildTextField(_usernameController, 'Nom', Icons.person),
              SizedBox(height: 15.0),
              _buildTextField(_passwordController, 'Mot de passe', Icons.lock, obscureText: true),
              SizedBox(height: 15.0),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Connexion'),
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

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData iconData,
      {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(iconData, color: Color(0xff052555)),
          labelText: labelText,
        ),
        obscureText: obscureText,
      ),
    );
  }
}
