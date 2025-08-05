import 'package:flutter/material.dart';
import 'home.dart';
import 'favoris.dart';
import 'ajout.dart';
// import 'dashbord.dart';
import 'profil.dart';
import 'annotation.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Liste des widgets pour chaque page
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),              // Page d'accueil
    FavorisPage(),           // Page des favoris
    AddDocumentPage(),       // Page d'ajout de document
    AnnotationListPage(),
    // DashboardPage(),         // Page de tableau de bord
    ProfilPage(),            // Page de profil

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3571CB),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '', // Empty label to hide the text
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '', // Empty label to hide the text
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 60, // Adjust width if needed
              height: 60, // Adjust height if needed
              decoration: BoxDecoration(
                color: Colors.white, // Background color for the "Add" button
                shape: BoxShape.circle, // Make it circular
                boxShadow: [ // Optional: Add shadow for better visibility
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.add, color: Colors.blue), // Icon color
            ),
            label: '', // Empty label to hide the text
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: '', // Empty label to hide the text
          ),


          


          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '', // Empty label to hide the text
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black,
        showSelectedLabels: false, // Hide selected labels
        showUnselectedLabels: false, // Hide unselected labels
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure fixed type to prevent shifting
      ),
    );
  }
}
