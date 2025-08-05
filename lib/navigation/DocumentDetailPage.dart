import 'package:flutter/material.dart';

class DocumentDetailPage extends StatelessWidget {
  final String title;
  final String summary;

  const DocumentDetailPage({
    Key? key,
    required this.title,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détail du document"),
        backgroundColor: Colors.teal[700],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.grey.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Pour centrer le titre
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.centerLeft,  // <-- IMPORTANT : force l'alignement à gauche
                    child: Text(
                      summary,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left, // optionnel
                    ),
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
