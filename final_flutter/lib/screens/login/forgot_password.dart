// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// SCREEN
import 'package:final_flutter/home.dart';
import 'package:final_flutter/screens/login/register_sreen.dart';
// Button
import 'package:flutter_social_button/flutter_social_button.dart';
// FIREBASE
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_service.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<ForgotPassword> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSigning = false;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  Future<void> _forgotPassword() async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Password reset link sent! Check your email'),
        );
      }
    ).then((_) {
      // Sau khi hiển thị hộp thoại, quay lại màn hình trước đó (Login)
      Navigator.pop(context);
    });
  } on FirebaseAuthException catch (e) {
    print(e);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(e.message.toString()),
        );
      }
    );
  }
  
  _formKey.currentState!.validate();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor:  Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'FORGOT YOUR ACCOUNT?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 64.0,left: 64),
                  child: Text(
                    'Don\'t worry! Enter your email and we will send you a reset',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:BorderSide(color: Colors.white)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:BorderSide(color: Colors.deepPurple)
                          ),
                          hintText: 'Email',
                          fillColor: Colors.grey[200],
                          filled: true
                        ),
                        validator: (String? value) {
                          final RegExp emailRegExp =
                              RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegExp.hasMatch(value ?? '')) {
                            _focusNode.requestFocus();
                            return 'Email is not in the correct format';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                      child: ElevatedButton(
                        onPressed: _forgotPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // border radius
                          ),
                        ),
                        child: _isSigning
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'SEND REQUEST',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                      ),
                    ),
                    
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
