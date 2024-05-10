
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String? id;
  final String? imageLink;
  final String? userName;
  final String email;
  final String? birthDay;
  final String? gender;

  UserModel({required this.id, required this.userName, required this.email, this.birthDay, this.gender, this.imageLink}); 

  toJson(){
    return {
      "id" : id,
      "userName": userName,
      "email" : email,
      "birthDay" : birthDay,
      "gender" : gender,
      "imageLink" : imageLink
    };
  }


}