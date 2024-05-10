import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/models/user.dart';
import 'package:final_flutter/screens/login/firebase_auth_service.dart';
import 'package:final_flutter/screens/login/login_screen.dart';
import 'package:final_flutter/screens/profile/profile_Controller.dart';
import 'package:final_flutter/widgets/uploadImage.dart';
import 'package:final_flutter/widgets/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({Key? key}) : super(key: key);

  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _birthDayController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? userName;
  Uint8List? _image;
  String gender = '';
  bool _isUpdate = false;
  DateTime? _selectedDate;
  String userID = '';
  final _formKey = GlobalKey<FormState>();
  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }
  final controller = Get.put(ProfileController());

  
  void loadUserData() async {
    gender = _genderController.text;
    controller.getUserData().then((userDetails) async {
      if (userDetails != null) {
        _usernameController.text = userDetails.userName ?? "";
        _emailController.text = userDetails.email ?? "";
        _birthDayController.text = userDetails.birthDay ?? "";
        _genderController.text = userDetails.gender ?? "";
        userID = userDetails.id ?? "";
        // Lấy ảnh từ Firebase Storage
        if (userDetails.imageLink != null) {
          Uint8List? imageBytes =
              await controller.loadImageFromStorage(userDetails.imageLink!);
          if (imageBytes != null) {
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
    loadUserData();
  }

  void updateUserDetails() async{
    String updatedUsername = _usernameController.text;
    String updatedEmail = _emailController.text;
    String updatedBirthDay = _birthDayController.text;
    String updatedGender = _genderController.text;

    
    controller.updateUserData(updatedUsername, updatedEmail, updatedBirthDay, updatedGender);

    setState(() {
      _isUpdate = !_isUpdate; 
    });

    if(!_isUpdate){
      if(_image != null) String resp = await StoreData().saveData(id: userID, file: _image!);
    }
  }
  


  void _showCountryBottomSheet(BuildContext context) async {
  final selectedGender = await showModalBottomSheet<String>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: genderList.length,
                itemBuilder: (context, index) {
                  final gender = genderList[index];
                  return ListTile(
                    title: Text(gender),
                    onTap: () {
                      Navigator.pop(context, gender);
                    },
                    trailing: _genderController.text == gender ? Icon(Icons.check, color: Colors.green,) : null, // Display check mark icon next to selected country
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  if (selectedGender != null) {
    setState(() {
      _genderController.text = selectedGender;
    });
  }
}

  final List<String> genderList = [
  'Nam',
  'Nữ',
];
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin chi tiết'),
      ),
      body: SingleChildScrollView(
        child: Container(
            height: screenSize.height,
            color: Colors.teal,
            child: Column(
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                                          backgroundColor: const Color.fromRGBO(
                                              187, 237, 242, 1),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(top: 32.0),
                                      child: CircleAvatar(
                                        radius: 68,
                                        backgroundColor: Colors.teal,
                                        child: CircleAvatar(
                                          radius: 64,
                                          backgroundImage:NetworkImage(
                                              'https://static-00.iconduck.com/assets.00/avatar-default-dark-icon-512x512-3ixx3cy9.png'),
                                          backgroundColor:
                                              Color.fromRGBO(187, 237, 242, 1),
                                        ),
                                      ),
                                    ),
                              Positioned(
                                  bottom: -10,
                                  left: 90,
                                  child: IconButton(
                                    onPressed: _isUpdate ? selectImage : null,
                                    icon: const Icon(Icons.add_a_photo),
                                    iconSize: 32,
                                  )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 50, right: 24, left: 24, bottom: 20),
                            child: TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              enabled: _isUpdate,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.deepPurple)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                labelText: 'Username',
                                hintText: 'Username',
                                fillColor: Colors.grey[300],
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 24, left: 24, bottom: 20),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: _isUpdate,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.deepPurple)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                labelText: 'Email',
                                hintText: 'Email',
                                fillColor: Colors.grey[300],
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 24, left: 24, bottom: 20),
                            child: TextFormField(
                              controller: _birthDayController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              readOnly: true,
                              enabled: _isUpdate,
                              decoration: InputDecoration(
                                suffix: Icon(Icons.calendar_today),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.deepPurple)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                labelText: 'BirthDay',
                                hintText: 'Enter your birthday',
                                fillColor: Colors.grey[300],
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().subtract(
                                      Duration(days: 365 * 18)), // Adjusted initialDate
                                  firstDate:
                                      DateTime.now().subtract(Duration(days: 365 * 99)),
                                  lastDate:
                                      DateTime.now().subtract(Duration(days: 365 * 18)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                    _birthDayController.text = "${picked.day}/${picked.month}/${picked.year}";
                                  });
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 24, left: 24),
                            child: GestureDetector(
                      onTap: () => _showCountryBottomSheet(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                              controller: _genderController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: _isUpdate,
                              readOnly: true,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.deepPurple)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal)),
                                labelText: 'Gender',
                                hintText: 'Choose your gender',
                                fillColor: Colors.grey[300],
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                            ),
                          ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 24.0, right: 24.0, bottom: 20),
                            child: ElevatedButton(
                              onPressed: () => updateUserDetails(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      16), // border radius
                                ),
                              ),
                              child: _isUpdate
                                  ? const Text(
                                      'Cập nhật',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    )
                                  : const Text(
                                      'Chỉnh sửa',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

