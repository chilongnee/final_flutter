import 'dart:typed_data';

import 'package:final_flutter/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController{
  static UserRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(BuildContext context, UserModel user) async {
    try {
      await _db.collection("users").add(user.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your account has been created."),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (error, stackTrace) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong. Please try again!"),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }


  Future<UserModel?> getUserDetails(String id) async {
  final snapshot = await _db.collection("users").where("id", isEqualTo: id).get();

  if (snapshot.docs.isNotEmpty) {
    final data = snapshot.docs.first.data();
    
    // Kiểm tra dữ liệu trước khi tạo đối tượng UserModel
    if (data != null && data.isNotEmpty) {
       snapshot.docs.forEach((doc) {
        print(doc.data()); // In ra dữ liệu của tài liệu
      }); 

      return UserModel(
        id: data["id"] ?? "", 
        userName: data["userName"] ?? "", 
        email: data["email"] ?? "",
        birthDay: data["birthDay"] ?? "",
        gender: data["gender"] ?? "",
        imageLink: data["imageLink"] ?? "",
      );
    } else {
      // Trường hợp dữ liệu rỗng
      print("Dữ liệu người dùng rỗng hoặc không tồn tại");
      return null;
    }
  } else {
    // Trường hợp không tìm thấy tài liệu
    print("Không tìm thấy tài liệu người dùng với ID: $id");
    return null;
  }
}

Future<Map<String, String>> getUserAndCourse() async {
  Map<String, String> userData = {};

  final User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: user.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userDataFromFirestore = snapshot.docs.first.data() as Map<String, dynamic>;

      // Lấy userID và courseID từ dữ liệu
      final String userId = user.uid;
      final String? courseId = userDataFromFirestore['courseId'];


      userData['userId'] = userId;
      userData['courseId'] = courseId ?? "";

      return userData;
    }
  }

  // Trả về map rỗng nếu không có dữ liệu
  return userData;
}



Future<void> updateUserData(String id, String updatedUsername, String updatedEmail, String updatedBirthDay, String updatedGender) async {
  try {
    // Tìm tài liệu với field "id" bằng giá trị được cung cấp
    final snapshot = await _db.collection("users").where("id", isEqualTo: id).get();

    // Nếu tìm thấy tài liệu, cập nhật nó
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        "userName": updatedUsername,
        "email": updatedEmail,
        "birthDay": updatedBirthDay,
        "gender": updatedGender,
      });
      print("Dữ liệu người dùng đã được cập nhật thành công.");
    } else {
      // Nếu không tìm thấy tài liệu, thông báo lỗi
      print("Không tìm thấy tài liệu người dùng với ID: $id");
    }
  } catch (error) {
    print("Lỗi khi cập nhật dữ liệu người dùng: $error");
    throw error;
  }
}



}
