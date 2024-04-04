import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData{
  Future<String> uploadImageToStorage(String childName, Uint8List file) async{

    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;

    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> saveData({required String name, required Uint8List file,}) async {
    String resp = " Some Error Occurred";
    try{
      String imageURL = await uploadImageToStorage('ProfileImage', file);
      await _firestore.collection('userProfile').add({
        'name' : name,
        'imageLink' : imageURL,
      });
      resp = 'success';


    }catch(err){
      resp = err.toString();
    }
    return resp;
  }
}