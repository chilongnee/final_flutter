import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                    _buildBox('Thẻ ghi nhớ'),
                    _buildBox('Học (Quiz, Type)'),
                    _buildBox('Kiểm tra'),
                    _buildBox('Xếp hạng'),
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

  Widget _buildBox(String title) {
    return Container(
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
    );
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
                    final String vocabularyName = vocabulary['definition'];
                    final String vocabularyMeaning = vocabulary['term'];
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocabularyName,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
    );
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
}
