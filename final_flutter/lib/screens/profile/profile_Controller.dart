import 'dart:typed_data';

import 'package:final_flutter/screens/login/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController{
  static ProfileController get instance => Get.find();

  final _userRepo = Get.put(UserRepository());

  
  
  getUserData(){
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      return _userRepo.getUserDetails(user.uid);
    }else {
      return null;
    }
  }

  updateUserData(String updatedUsername, String updatedEmail, String updatedBirthDay, String updatedGender){
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
    return _userRepo.updateUserData(user.uid, updatedUsername, updatedEmail, updatedBirthDay, updatedGender);
    }else {
      return null;
    }
  }

  Future<Uint8List?> loadImageFromStorage(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) {
    return null;
  }

  // Kiểm tra nếu imageUrl không có địa chỉ URL hợp lệ
  if (!Uri.parse(imageUrl).isAbsolute) {
    print('Invalid URL: $imageUrl');
    return null;
  }

  // Tải ảnh từ URL
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    print('200');
    return response.bodyBytes;
  } else {
    print('Failed to load image: ${response.statusCode}');
    return null;
  }
}

  
}
