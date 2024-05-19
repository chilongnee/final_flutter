import 'package:final_flutter/models/user.dart';
import 'package:final_flutter/screens/login/user_repository.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
// WIDGET
import 'package:final_flutter/widgets/uploadImage.dart';
import 'package:final_flutter/widgets/utils.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// FIREBASE
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth_service.dart';
// SCREEN
import 'package:final_flutter/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final cfpasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureText2 = true;
  final bool _rememberMe = false;
  bool _isSigningUp = false;
  final FocusNode _username = FocusNode();
  final FocusNode _email = FocusNode();
  final FocusNode _password = FocusNode();
  final FocusNode _cfpassword = FocusNode();

  final userRepo = Get.put(UserRepository());

  void _signUp() async {
    setState(() {
      _isSigningUp = true;
    });
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    User? user = await _auth.createUserWithEmailAndPassWord(
        context: context, email: email, password: password);

    setState(() {
      _isSigningUp = false;
    });

    if (user != null) {
      print("User is successfully created");

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid,
        'userName': username,
        'email': email,
      });


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      print("Some error happend");
    }
  }

  @override
  Widget build(BuildContext context) {
    var width =  MediaQuery.of(context).size.width;
    var height =  MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 80, right: 30, left: 30),
                    child: Image.asset('assets/LHT2.png'),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 75.0),
                        child: Text(
                          'WELCOME',
                          style: TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Sign up to continue',
                        style: TextStyle(fontSize: 24),
                      )
                    ],
                  )
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 50, right: 24, left: 24, bottom: 8.0),
                      child: SizedBox(
                        height: 80,
                        child: TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.deepPurple)),
                              hintText: 'User Name',
                              fillColor: Colors.white,
                              filled: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            if (value.length < 6) {
                              return 'Username must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 24, left: 24, bottom: 8),
                      child: SizedBox(
                        height: 80,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.deepPurple)),
                              hintText: 'Email',
                              fillColor: Colors.white,
                              filled: true),
                          validator: (String? value) {
                            final RegExp emailRegExp =
                                RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegExp.hasMatch(value ?? '')) {
                              _email.requestFocus();
                              return 'Email is not in the correct format';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 24.0, right: 24.0, bottom: 8.0),
                      child: SizedBox(
                        height: 80,
                        child: TextFormField(
                          focusNode: _password,
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                          obscureText: _obscureText,
                          maxLength: 20,
                          decoration: InputDecoration(
                            counterText: '',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.deepPurple)),
                            hintText: 'Password',
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.length < 6) {
                              _password.requestFocus();
                              return "Password should have at least 6 characters";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 24, left: 24, bottom: 0),
                      child: SizedBox(
                        height: 80,
                        child: TextFormField(
                          focusNode: _cfpassword,
                          controller: cfpasswordController,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscureText2,
                          maxLength: 20,
                          decoration: InputDecoration(
                            counterText: '',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white)), 
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.deepPurple)),
                            hintText: 'Password',
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: IconButton(
                                icon: Icon(
                                  _obscureText2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText2 = !_obscureText2;
                                  });
                                },
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.length < 6) {
                              _cfpassword.requestFocus();
                              return "Password should have at least 6 characters";
                            } else if (value != _passwordController.text) {
                              _cfpassword.requestFocus();
                              return "Confirm password do not match";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24, left: 24.0, right: 24.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSigningUp
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'SIGN UP',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already a member? ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login here',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
