import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/models/user.dart';
import 'package:final_flutter/screens/login/firebase_auth_service.dart';
import 'package:final_flutter/screens/login/login_screen.dart';
import 'package:final_flutter/screens/profile/profile_Controller.dart';
import 'package:final_flutter/screens/profile/profile_details.dart';
import 'package:final_flutter/screens/profile/star_list_view.dart';
import 'package:final_flutter/widgets/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';




class Profile extends StatefulWidget {

  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userName;
  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }
  void _logOut() async {
    await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
  void _editProfile() async {
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileDetails()),
    );
  }
 final controller = Get.put(ProfileController());
Future<void> loadImage() async {
  controller.getUserData().then((userDetails) async {
      if (mounted && userDetails != null) {
        // Lấy ảnh từ Firebase Storage
        if (userDetails.imageLink != null || userDetails.imageLink != "") {
          Uint8List? imageBytes =
              await controller.loadImageFromStorage(userDetails.imageLink!);
          if (mounted &&imageBytes != null) {
            setState(() {
              _image = imageBytes;
            });
          }
        }
      }
    });
}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      loadImage();
    });
  }
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: screenSize.height * 0.817,
          color: Colors.teal.shade200,
          child: FutureBuilder(
            future: controller.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  UserModel userData = snapshot.data as UserModel;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 15, right: 15, bottom: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // Màu nền là trắng
                            borderRadius:
                                BorderRadius.circular(12), // Bo viền container
                            border: Border.all(
                              // Thiết lập border cho container
                              color: Colors.teal, // Màu border là teal
                              width: 2, // Độ dày của border
                            ),
                          ),
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 15.0, left: 10),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [ 
                                              _image != null
                                                ? CircleAvatar(
                                                  radius: screenSize.height * 0.047,
                                                  backgroundColor: Colors.teal,
                                                  child: CircleAvatar(
                                                    radius: screenSize.height * 0.041,
                                                    backgroundImage: MemoryImage(_image!),
                                                    backgroundColor: const Color.fromRGBO(
                                                        187, 237, 242, 1),
                                                  ),
                                                )
                                                : CircleAvatar(
                                                  radius: screenSize.height * 0.047,
                                                  backgroundColor: Colors.teal,
                                                  child: CircleAvatar(
                                                    radius: screenSize.height * 0.041,
                                                    backgroundImage:NetworkImage(
                                                        'https://static-00.iconduck.com/assets.00/avatar-default-dark-icon-512x512-3ixx3cy9.png'),
                                                    backgroundColor:
                                                        Color.fromRGBO(187, 237, 242, 1),
                                                  ),
                                                ),
                                              ElevatedButton(
                                                onPressed: () => _editProfile(),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.teal,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  minimumSize: Size(
                                                      screenSize.width * 0.005,
                                                      screenSize.height * 0.04),
                                                ),
                                                child: Text('Sửa',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 1.0, bottom: 5, left: 20),
                                                child: Text(
                                                     userData.userName ?? 'Tên người dùng',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 20, bottom: 5),
                                                child: Text('Email: ' + 
                                                    userData.email ?? 'Email',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.normal),
                                                    textAlign: TextAlign.left,
                                                    
                                                      ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 20,bottom: 5),
                                                child: Text('Ngày sinh: ' + (
                                                    userData.birthDay ?? 'Trống'),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.normal),
                                                        textAlign: TextAlign.left,),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 20,left: 20),
                                                child: Text('Giới tính: ' + (
                                                    userData.gender ?? 'Trống'),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.normal),
                                                        textAlign: TextAlign.left,),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only( left: 15, right: 15, bottom: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // Màu nền là trắng
                            borderRadius:
                                BorderRadius.circular(12), // Bo viền container
                            border: Border.all(
                              // Thiết lập border cho container
                              color: Colors.teal, // Màu border là teal
                              width: 2, // Độ dày của border
                            ),
                          ),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10, left: 20),
                                child: Text(
                                    'Thành tích của tôi',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 32.0,right: 32, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        CircleAvatar(
                                          radius: screenSize.height * 0.047,
                                          backgroundColor: Colors.teal,
                                          child: CircleAvatar(
                                            radius: screenSize.height * 0.041,
                                            backgroundImage: NetworkImage(
                                                'https://cdn-icons-png.freepik.com/512/5987/5987773.png'),
                                            backgroundColor:
                                                Colors.white,
                                          ),
                                        ),
                                        Text('21 TOPICS',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                        Text('Mastered'),
                                    ]),
                                    Column(
                                      children: [
                                        CircleAvatar(
                                          radius: screenSize.height * 0.047,
                                          backgroundColor: Colors.teal,
                                          child: CircleAvatar(
                                            radius: screenSize.height * 0.041,
                                            backgroundImage: NetworkImage(
                                                'https://i.pinimg.com/originals/ea/ca/4f/eaca4fcb632754945995f7927a8d4aec.png'),
                                            backgroundColor:
                                                Colors.white,
                                          ),
                                        ),
                                        Text('169 WORDS',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                        Text('Learned'),
                                    ]),
                                    Column(
                                      children: [
                                        CircleAvatar(
                                          radius: screenSize.height * 0.047,
                                          backgroundColor: Colors.teal,
                                          child: CircleAvatar(
                                            radius: screenSize.height * 0.041,
                                            backgroundImage: NetworkImage(
                                                'https://cdn-icons-png.flaticon.com/512/7937/7937682.png'),
                                            backgroundColor:
                                                Colors.white,
                                          ),
                                        ),
                                        Text('7 TOPICS',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                        Text('Created'),
                                    ])
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only( left: 15, right: 15, bottom: 25),
                        child: GestureDetector (
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StarListView(userId: userData.id?? '')),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Màu nền là trắng
                              borderRadius:
                                  BorderRadius.circular(12), // Bo viền container
                              border: Border.all(
                                // Thiết lập border cho container
                                color: Colors.teal, // Màu border là teal
                                width: 2, // Độ dày của border
                              ),
                            ),
                            alignment: Alignment.topLeft,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 10, left: 20),
                                  child: Text(
                                      'Xem các từ vựng đã note',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 32.0,right: 32),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      ElevatedButton(
                        onPressed: () => _logOut(),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Điều chỉnh giá trị này
                          ),
                          minimumSize: Size(screenSize.width -30, screenSize.height * 0.06),
                          backgroundColor: Colors.white,
                          
                        ),
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(fontSize: 20,color: Colors.teal),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError){
                  print("error: "+ snapshot.data.toString());
                  return Center(child: Text(snapshot.error.toString()),);
                } else {
                  return Center(child: Column(
                    children: [
                      Text("Something went wrong!"),
                      ElevatedButton(
                          onPressed: () => _logOut(),
                          child: Text('Đăng xuất',
                              style: TextStyle(fontSize: 20))),
                    ],
                  ));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

