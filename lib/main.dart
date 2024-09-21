import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gunes_saati/pages/splash.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(); 
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Güneş Saati',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false, 
      
    );
  }
}

class BackgroundScaffold extends StatelessWidget {
  final Widget body;

  BackgroundScaffold({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', 
              fit: BoxFit.cover,
            ),
          ),
          body,
        ],
      ),
    );
  }
}