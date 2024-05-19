import 'package:final_flutter/screens/folder_course/course_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  Set<String> _displayedCourseIds = {};

  Future<List<DocumentSnapshot>> _fetchPublicCourses() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('courses')
        .where('status', isEqualTo: 'Mọi người')
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.teal.shade200,
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _fetchPublicCourses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No public courses available'));
            } else {
              List<DocumentSnapshot> courses = snapshot.data!;
              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot course = courses[index];
                  if (_displayedCourseIds.contains(course.id)) {
                    return const SizedBox.shrink();
                  }
                  _displayedCourseIds.add(course.id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetail(
                            courseId: course.id,
                            userId: course['userId'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: screenWidth,
                      margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Image.asset('assets/LHT2.png', fit:BoxFit.cover)),
                            SizedBox(width: screenWidth * 0.08,),
                          Expanded(
                            flex:2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course['title'] ?? 'No Title',
                                  style: const TextStyle(
                                      fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Created by ${course['username'] ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                if (course['progress'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: course['progress'] == 'Hoàn thành'
                                    ? Text(
                                      course['progress'] ?? '',
                                      style: const TextStyle(fontSize: 16.0, color: Colors.green),
                                    )
                                    :Text(
                                      course['progress'] ?? '',
                                      style: const TextStyle(fontSize: 16.0, color: Colors.red),
                                    )
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
