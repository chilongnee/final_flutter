import 'package:flutter/material.dart';
import 'dart:typed_data';
// WIDGET
import 'package:final_flutter/widgets/uploadImage.dart';
import 'package:final_flutter/widgets/utils.dart';
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
  Uint8List? _image;
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

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void _signUp() async {
    setState(() {
      _isSigningUp = true;
    });
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.createUserWithEmailAndPassWord(
        email: email, password: password);

    setState(() {
      _isSigningUp = false;
    });

    if (user != null) {
      print("User is successfully created");

      // Lưu username
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(187, 237, 242, 1),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    color: Colors.black,
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 80, right: 30, left: 30),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 54.0),
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
              Stack(
                children: [
                  _image != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: CircleAvatar(
                            radius: 68,
                            backgroundColor: Colors.teal,
                            child: CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                              backgroundColor:
                                  const Color.fromRGBO(187, 237, 242, 1),
                            ),
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.only(top: 32.0),
                          child: CircleAvatar(
                            radius: 68,
                            backgroundColor: Colors.teal,
                            child: CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(
                                  'https://static-00.iconduck.com/assets.00/avatar-default-dark-icon-512x512-3ixx3cy9.png'),
                              backgroundColor: Color.fromRGBO(187, 237, 242, 1),
                            ),
                          ),
                        ),
                  Positioned(
                      bottom: -10,
                      left: 90,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                        iconSize: 32,
                      )),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24.0, left: 24.0, right: 24.0, bottom: 15.0),
                      child: SizedBox(
                        height: 65,
                        child: TextFormField(
                          focusNode: _username,
                          controller: _usernameController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            hintText: 'Username',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null) {
                              _username.requestFocus();
                              return "Username cannot be blank";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 24.0, right: 24.0, bottom: 15.0),
                      child: SizedBox(
                        height: 65,
                        child: TextFormField(
                          focusNode: _email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            hintText: 'Email',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                            ),
                          ),
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
                          top: 0.0, left: 24.0, right: 24.0, bottom: 0.0),
                      child: SizedBox(
                        height: 80,
                        child: TextFormField(
                          focusNode: _password,
                          controller: _passwordController,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscureText,
                          maxLength: 20,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            hintText: 'Password',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                            ),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            hintText: 'Confirm Password',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                            ),
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
                          // validator: (String? value) {
                          //   if (value == null || value.length < 6) {
                          //     _cfpassword.requestFocus();
                          //     return "Password should have at least 6 characters";
                          //   }
                          //   return null;
                          // },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24, left: 24.0, right: 24.0),
                      child: ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // border radius
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
