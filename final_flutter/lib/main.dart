import 'package:firebase_auth/firebase_auth.dart';
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
      apiKey: "AIzaSyC6RU0OApSLBSVbE-5LXLBga1RciSh2ziQ",
      appId: "1:49611684810:android:2630335e488b2470946d33",
      messagingSenderId: "49611684810",
      projectId: "english-app-final",
      storageBucket: "gs://english-app-final.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  
       MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWidget(), // Use AuthWidget instead of Login directly
        debugShowCheckedModeBanner: false,
      
    );
  }
}

class AuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  Widget firstWidget;

  if (firebaseUser != null) {
    firstWidget = Home();
  } else {
    firstWidget = Login();
  }
    return firstWidget;
  }
}
