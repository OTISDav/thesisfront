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
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // colors: [
            //   Color.fromARGB(255, 15, 15, 15),
            //   Color.fromARGB(255, 44, 48, 49),
            //   Color.fromARGB(255, 15, 15, 15),
            // ],
            colors: [Color(0xFF2F6D78), Color(0xFFAAC4C4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Détail du document"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // centre le titre
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
                      alignment: Alignment.centerLeft, // aligne à gauche le résumé
                      child: Text(
                        summary,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
