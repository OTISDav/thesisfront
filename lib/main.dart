import 'package:flutter/material.dart';
import 'navigation/welcomepage.dart';
import 'auth/api_service.dart';

void main() {
  final apiService = ApiService('http://127.0.0.1:8000');
  
  runApp(MyApp(apiService));
}

class MyApp extends StatelessWidget {

  final ApiService apiService;

  MyApp(this.apiService);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thesis App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: welcome(),
    );
  }
}
