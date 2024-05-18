import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseSelectionScreen extends StatefulWidget {
  final String userId;

  const CourseSelectionScreen({super.key, required this.userId});

  @override
  _CourseSelectionScreenState createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final Set<String> _selectedCourses = {};

  void _toggleSelection(DocumentSnapshot course) {
    setState(() {
      final courseId = course.id;
      Set<String> updatedCourses = Set.from(_selectedCourses);
      if (updatedCourses.contains(courseId)) {
        updatedCourses.remove(courseId);
      } else {
        updatedCourses.add(courseId);
      }

      print("COURSE ID:$updatedCourses");

      _selectedCourses.clear();
      _selectedCourses.addAll(updatedCourses);
    });
  }

  bool _isSelected(DocumentSnapshot course) {
    final courseId = course.id;
    return _selectedCourses.contains(courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBEDF2),
      appBar: AppBar(
        title: const Text('Chọn khóa học'),
        actions: [
          TextButton(
            onPressed: () {
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
                final courseTitle = course['title'];
                return GestureDetector(
                  onTap: () {
                    _toggleSelection(course);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: _isSelected(course)
                          ? Colors.blue // Màu nền khi được chọn
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: _isSelected(course)
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
