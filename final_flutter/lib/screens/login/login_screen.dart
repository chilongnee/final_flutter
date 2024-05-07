import 'package:final_flutter/screens/login/forgot_password.dart';
import 'package:flutter/material.dart';
// SCREEN
import 'package:final_flutter/home.dart';
import 'package:final_flutter/screens/login/register_sreen.dart';
// Button
import 'package:flutter_social_button/flutter_social_button.dart';
// FIREBASE
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_service.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isSigning = false;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });
    _formKey.currentState!.validate();
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassWord(
        email: email, password: password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      print("Sign in successfully!!");
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
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(
                  top: 50,
                  right: 250,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/LHT2.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // child: Image.asset('assets/LHT2.png'),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 50,
                ),
                child: const Text(
                  'HELLO THERE,\nWELCOME BACK',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 172, top: 20),
                child: const Text(
                  'Sign in to countinue',
                  style: TextStyle(
                    fontSize: 20,
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
                        focusNode: _focusNode,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                          fillColor: Colors.white,
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
                      padding:
                          const EdgeInsets.only(right: 24, left: 24, bottom: 0),
                      child: TextFormField(
                        focusNode: _focusNode2,
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        obscureText:
                            _obscureText, // Use the _obscureText variable here
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:BorderSide(color: Colors.white)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:BorderSide(color: Colors.deepPurple)
                          ),
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
                            _focusNode2.requestFocus();
                            return "Password should have at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 24.0, bottom: 24),
                      child: Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.black,
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Remember Me",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                          const SizedBox(width: 110),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  ForgotPassword()),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                      child: ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // border radius
                          ),
                        ),
                        child: _isSigning
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 60.0, right: 60.0, top: 24, bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: Divider(color: Colors.black)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or'),
                          ),
                          Expanded(child: Divider(color: Colors.black)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlutterSocialButton(
                          onTap: () {},
                          buttonType: ButtonType.facebook,
                          mini: true,
                        ),
                        FlutterSocialButton(
                          onTap: () {},
                          buttonType: ButtonType.google,
                          mini: true,
                        ),
                        FlutterSocialButton(
                          onTap: () {},
                          buttonType: ButtonType.linkedin,
                          mini: true,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Not a member? ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUp()),
                              );
                            },
                            child: const Text(
                              'Create an account',
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
            ],
          ),
        ),
      ),
    );
  }
}
