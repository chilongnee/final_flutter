import 'package:final_flutter/screens/folder_course/memory_card.dart';
import 'package:final_flutter/screens/folder_course/summarize_memory_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CourseDetail extends StatefulWidget {
  final String userId;
  final String courseId;

  const CourseDetail({
    super.key,
    required this.userId,
    required this.courseId,
  });

  @override
  _CourseDetailState createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  late Future<DocumentSnapshot> _courseFuture;
  late FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _courseFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: _courseFuture,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else if (!snapshot.hasData) {
              return const Text('Course not found');
            } else {
              final courseData = snapshot.data!;
              final String courseTitle = courseData['title'];
              return Text(courseTitle);
            }
          },
        ),
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: const Color(0xFFBBEDF2),
        child: FutureBuilder(
          future: _courseFuture,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Course not found'));
            } else {
              final courseData = snapshot.data!;
              final String courseTitle = courseData['title'];
              final String progress = courseData['progress'];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.grey[200],
                              // image: DecorationImage(
                              //   image: NetworkImage('URL_HINH_ANH'),
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                            child: const Icon(Icons.image),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              courseTitle,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildBox(context, 'Thẻ ghi nhớ'),
                    _buildBox(context, 'Học (Quiz, Type)'),
                    _buildBox(context, 'Kiểm tra'),
                    _buildBox(context, 'Xếp hạng'),
                    const SizedBox(height: 16.0),
                    _buildBoxForVocabularies(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        _handleBoxTap(context, title);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }

  void _handleBoxTap(BuildContext context, String title) {
    // Thực hiện điều gì đó dựa vào title
    // Ví dụ: chuyển sang màn hình tương ứng với title
    switch (title) {
      case 'Thẻ ghi nhớ':
        navigateToSummarize(context);
        break;
      case 'Học (Quiz, Type)':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MemoryCardScreen(
                  userId: widget.userId, courseId: widget.courseId)),
        );
        break;
      case 'Kiểm tra':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MemoryCardScreen(
                  userId: widget.userId, courseId: widget.courseId)),
        );
        break;
      case 'Xếp hạng':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MemoryCardScreen(
                  userId: widget.userId, courseId: widget.courseId)),
        );
        break;
      default:
        // Xử lý mặc định nếu không có trường hợp nào khớp
        break;
    }
  }

  Widget _buildBoxForVocabularies() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder(
        future: _fetchVocabularies(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            final List<DocumentSnapshot> vocabularies = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Các từ vựng:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: vocabularies.map((DocumentSnapshot vocabulary) {
                    final List<dynamic> types = vocabulary['types'];
                    final String vocabularyName = vocabulary['term'];
                    final String vocabularyMeaning = vocabulary['definition'];
                    return _buildBoxForVocabulary(
                        vocabularyName, vocabularyMeaning, types);
                  }).toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildBoxForVocabulary(
      String vocabularyName, String vocabularyMeaning, List<dynamic> types) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocabularyName,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  vocabularyMeaning,
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: types
                      .map((type) => Chip(
                            label: Text(
                              type.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              _speak(vocabularyName);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  Future<List<DocumentSnapshot>> _fetchVocabularies() async {
    final QuerySnapshot vocabularySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .get();
    return vocabularySnapshot.docs;
  }

  Future<void> navigateToSummarize(BuildContext context) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .get();

    int learnedCount = 0;
    int studyingCount = 0;
    for (var doc in querySnapshot.docs) {
      if ((doc.data() as Map<String, dynamic>)['status'] == 'Đã biết') {
        learnedCount++;
      } else if ((doc.data() as Map<String, dynamic>)['status'] == 'Đang học') {
        studyingCount++;
      }
    }
    // print("đã biết: $learnedCount");
    // print("length: ${querySnapshot.docs.length}");
    if (learnedCount == querySnapshot.docs.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SummarizeMemoryCard(
                studyingCount: studyingCount,
                learnedCount: learnedCount,
                courseId: widget.courseId,
                userId: widget.userId)),
      );
    } else if (learnedCount < querySnapshot.docs.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MemoryCardScreen(
                userId: widget.userId, courseId: widget.courseId)),
      );
    }
  }
}
