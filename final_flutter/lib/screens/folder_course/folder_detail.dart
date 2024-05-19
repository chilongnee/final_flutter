import 'package:final_flutter/screens/folder_course/edit_folder_screen.dart';
import 'package:final_flutter/screens/folder_course/folder_course_detail.dart';
import 'package:final_flutter/widgets/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_select_screen.dart';
import 'course_detail.dart';

class FolderDetail extends StatefulWidget {
  final String userId;
  final String folderId;

  const FolderDetail({
    super.key,
    required this.userId,
    required this.folderId,
  });

  @override
  _FolderDetailState createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  late Future<DocumentSnapshot> _folderFuture;
  late List<DocumentSnapshot> _coursesInFolder = [];

  @override
  void initState() {
    super.initState();
    _folderFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('folders')
        .doc(widget.folderId)
        .get();

    _loadCoursesInFolder();
  }

  Future<void> _loadCoursesInFolder() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('folders')
          .doc(widget.folderId)
          .collection('courses')
          .get();

      setState(() {
        _coursesInFolder = snapshot.docs;
      });
    } catch (e) {
      print("Error loading courses in folder: $e");
    }
  }

  void _addCourseToFolder(String courseId) async {
    try {
      final courseRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('courses')
          .doc(courseId);
      final courseData = await courseRef.get();

      if (courseData.exists) {
        Map<String, dynamic> courseInfo =
            courseData.data() as Map<String, dynamic>;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('folders')
            .doc(widget.folderId)
            .collection('courses')
            .doc(courseId)
            .set(courseInfo);

        final vocabSnapshot = await courseRef.collection('vocabularies').get();
        for (var vocabDoc in vocabSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('folders')
              .doc(widget.folderId)
              .collection('courses')
              .doc(courseId)
              .collection('vocabularies')
              .doc(vocabDoc.id)
              .set(vocabDoc.data());
        }

        await courseRef.collection('vocabularies').get().then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        await courseRef.delete();

        await _loadCoursesInFolder();
      } else {
        print("Course with ID $courseId does not exist.");
      }
    } catch (e) {
      print("Error retrieving course data: $e");
    }
  }

  void _removeCourseFromFolder(String courseId) async {
    try {
      final courseRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('folders')
          .doc(widget.folderId)
          .collection('courses')
          .doc(courseId);
      final courseData = await courseRef.get();

      if (courseData.exists) {
        Map<String, dynamic> courseInfo =
            courseData.data() as Map<String, dynamic>;

        // Sao chép thông tin của khóa học từ collection 'courses' của thư mục sang collection 'courses' của người dùng
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('courses')
            .doc(courseId)
            .set(courseInfo);

        // Sao chép từ vựng từ collection 'vocabularies' của thư mục sang collection 'vocabularies' của khóa học
        final vocabulariesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('folders')
            .doc(widget.folderId)
            .collection('courses')
            .doc(courseId)
            .collection('vocabularies')
            .get();
        for (var doc in vocabulariesSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('courses')
              .doc(courseId)
              .collection('vocabularies')
              .doc(doc.id)
              .set(doc.data());
        }

        await courseRef.delete();

        await _loadCoursesInFolder();
      } else {
        print("Course with ID $courseId does not exist.");
      }
    } catch (e) {
      print("Error removing course from folder: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: _folderFuture,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else if (!snapshot.hasData) {
              return const Text('Folder not found');
            } else {
              final folderData = snapshot.data!;
              final String folderTitle = folderData['title'];
              return Text(folderTitle);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return BottomSheetWidget(
                    height: 200,
                    buttons: const [
                      Text('Sửa thư mục'),
                      Text('Thêm học phần'),
                    ],
                    onPressed: (index) async {
                      switch (index) {
                        case 0:
                          final editedFolder = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditFolderScreen(
                                  userId: widget.userId,
                                  folderId: widget.folderId),
                            ),
                          );

                          if (editedFolder != null) {
                            for (String courseId in editedFolder) {
                              _removeCourseFromFolder(courseId);
                            }
                          }
                          break;
                        case 1:
                          final selectedCourses = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseSelectionScreen(userId: widget.userId),
                            ),
                          );

                          if (selectedCourses != null) {
                            for (String courseId in selectedCourses) {
                              _addCourseToFolder(courseId);
                            }
                          }
                          break;
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: const Color(0xFFBBEDF2),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              FutureBuilder(
                future: _folderFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error');
                  } else if (!snapshot.hasData) {
                    return const Text('Folder not found');
                  } else {
                    final folderData = snapshot.data!;
                    final String folderUsername =
                        folderData['username'] ?? 'Unknown';

                    return Container(
                      child: Text(
                        folderUsername,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16.0),
              _coursesInFolder.isNotEmpty
                  ? _buildCoursesInFolderList(screenSize.width)
                  : _buildAddCourseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCourseButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Thư mục này không có học phần',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Thêm học phần vào thư mục này để sắp xếp chúng',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          InkWell(
            onTap: () async {
              final selectedCourses = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CourseSelectionScreen(userId: widget.userId),
                ),
              );

              if (selectedCourses != null) {
                for (String courseId in selectedCourses) {
                  _addCourseToFolder(courseId);
                }
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              decoration: BoxDecoration(
                color: const Color(0xFFBBEDF2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8.0),
                  Text(
                    'Thêm học phần',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesInFolderList(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các khóa học trong thư mục:',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _coursesInFolder.length,
          itemBuilder: (BuildContext context, int index) {
            final course = _coursesInFolder[index];
            final courseId = course.id;
            final courseData = course.data() as Map<String, dynamic>;
            final courseTitle = courseData['title'] ?? 'No title';
            final courseProgress = courseData['progress'] ?? 'No progress';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderCourseDetail(
                      courseId: courseId,
                      folderId: widget.folderId,
                      userId: widget.userId,
                    ),
                  ),
                );
                print(widget.folderId);
              },
              child: Container(
                width: screenWidth,
                margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseTitle,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Progress: $courseProgress',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}