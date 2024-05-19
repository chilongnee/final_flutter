import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFolderScreen extends StatefulWidget {
  final String userId;
  final String folderId;

  const EditFolderScreen(
      {super.key, required this.userId, required this.folderId});

  @override
  _EditFolderScreenState createState() => _EditFolderScreenState();
}

class _EditFolderScreenState extends State<EditFolderScreen> {
  final Set<String> _selectedCourses = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBEDF2),
      appBar: AppBar(
        title: const Text('Chọn khóa học'),
        actions: [
          TextButton(
            onPressed: () {
              // Trả về danh sách các khóa học đã được chọn
              Navigator.pop(context, _selectedCourses.toList());
            },
            child: const Text(
              'Xong',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('folders')
            .doc(widget.folderId)
            .collection('courses')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No courses found'));
          } else {
            final courses = snapshot.data!.docs;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final courseId = course.id;
                final courseData = course.data() as Map<String, dynamic>;
                final courseTitle = courseData['title'];
                final isSelected = _selectedCourses.contains(courseId);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCourses.remove(courseId);
                      } else {
                        _selectedCourses.add(courseId);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : Colors.white, // Màu nền khi được chọn
                      borderRadius: BorderRadius.circular(10.0),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2.0)
                          : null,
                    ),
                    child: Text(courseTitle),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}