import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';



class StoreData {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> uploadImageToStorage(Uint8List file) async {
    Reference ref = _storage.ref().child('profileImage').child(DateTime.now().millisecondsSinceEpoch.toString());

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;

    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> saveData({required String id, required Uint8List file}) async {
    String resp = " Some Error Occurred";
    try {
      String imageURL = await uploadImageToStorage(file);
      final snapshot = await _firestore.collection('users').where('id', isEqualTo: id).get();
      // Nếu tìm thấy tài liệu, thêm dữ liệu mới vào
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'imageLink': imageURL,
        });
        resp = 'success';
      } else {
        // Nếu không tìm thấy tài liệu, thông báo lỗi
        resp = 'User with provided ID not found';
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }


}
