import 'package:flutter/material.dart';
import 'package:leftover_legends/pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leftover_Legends',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: LoginPage()
    );
  }
}
