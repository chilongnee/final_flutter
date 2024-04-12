import 'package:flutter/material.dart';
import 'home.dart';

// SCREEN
import 'package:final_flutter/screens/login/login_screen.dart';
import 'package:final_flutter/screens/login/register_sreen.dart';
// FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDNTGb-xiizr6BxvTZgPG4wMoilKGCma_U",
      appId: "1:239108711351:android:b31df33083edbebfad3e32",
      messagingSenderId: "239108711351",
      projectId: "final-flutter-80ee0",
    ),
  );
  runApp(const MyApp());
}

class DefaultFirebaseOptions {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}
