import 'dart:typed_data';

import 'package:final_flutter/screens/login/login_screen.dart';
import 'package:final_flutter/widgets/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }
  void _logOut() async {
  // Đăng xuất người dùng khỏi Firebase
  await FirebaseAuth.instance.signOut();
  
  // Sau khi đăng xuất thành công, chuyển người dùng đến trang đăng nhập
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Login()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          const Center(
            child: Text('Profile Screen', style: TextStyle(fontSize: 40)),
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
          ElevatedButton(onPressed: () => _logOut(), child: Text('Đăng xuất', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }
}
