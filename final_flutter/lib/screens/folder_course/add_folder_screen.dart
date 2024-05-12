import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFolderScreen extends StatelessWidget {
  const AddFolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    void addFolder() {
      String title = titleController.text;
      String description = descriptionController.text;

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userUid = user.uid;
        print(userUid);

        FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .get()
            .then((userSnapshot) {
          if (userSnapshot.exists) {
            String username = userSnapshot.data()?['username'] ?? 'Unknown';

            FirebaseFirestore.instance
                .collection('users')
                .doc(userUid)
                .collection('folders')
                .add({
              'title': title,
              'description': description,
              'userUid': userUid,
              'username': username,
            }).then((_) {
              Navigator.pop(context);
            }).catchError((error) {
              print('Error adding folder: $error');
            });
          } else {
            print('User not found');
          }
        }).catchError((error) {
          print('Error getting user data: $error');
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Yêu cầu đăng nhập'),
              content: const Text('Bạn cần đăng nhập để thêm thư mục.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      }

      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập Tên thư mục.'),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Folder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên thư mục',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (Tùy chọn)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addFolder,
              child: const Text('Thêm Thư Mục'),
            ),
          ],
        ),
      ),
    );
  }
}
