import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFolderScreen extends StatefulWidget {
  const AddFolderScreen({super.key});

  @override
  _AddFolderScreenState createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void addFolder() {
    String title = titleController.text;
    String description = descriptionController.text;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userUid = user.uid;

      FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get()
          .then((userSnapshot) {
        if (userSnapshot.exists) {
          String username = userSnapshot.data()?['userName'] ?? 'Unknown';

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
            print('CONTEXT $context');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Folder'),
      ),
      backgroundColor: const Color(0xFFBBEDF2),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addFolder,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(10)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Thêm Thư Mục',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
