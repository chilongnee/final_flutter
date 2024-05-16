import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StarListView extends StatefulWidget {
  final String userId;

  const StarListView({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _StarListViewState createState() => _StarListViewState();
}

class _StarListViewState extends State<StarListView> {
  late FlutterTts flutterTts;
  late Map<String, bool> _isClickedMap = {};

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  

  @override
Widget build(BuildContext context) {
  var screenSize = MediaQuery.of(context).size;
  return Scaffold(
    appBar: AppBar(
      title: Text('Các từ vựng đã note'),
    ),
    body: Container(
      height: screenSize.height,
      color: Colors.teal.shade200,
      child: StreamBuilder<QuerySnapshot>(
        stream: _fetchDataCourse(widget.userId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> courseSnapshot) {
          if (courseSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (courseSnapshot.hasError) {
            return const Center(child: Text('Error fetching course data'));
          } else if (!courseSnapshot.hasData || courseSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No courses found'));
          } else {
            final List<DocumentSnapshot> courses = courseSnapshot.data!.docs;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (BuildContext context, int index) {
                final course = courses[index];
                final String courseId = course.id;
                return StreamBuilder<QuerySnapshot>(
                  stream: _fetchDataVocabularies(widget.userId, courseId),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> vocabSnapshot) {
                    if (vocabSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (vocabSnapshot.hasError) {
                      return const Center(child: Text('Error fetching vocabulary data'));
                    } else if (!vocabSnapshot.hasData || vocabSnapshot.data!.docs.isEmpty) {
                      return const SizedBox(); // Không có vocabularies
                    } else {
                      final List<DocumentSnapshot> vocabularies = vocabSnapshot.data!.docs;
                      _isClickedMap = Map.fromIterable(
                        vocabularies,
                        key: (vocab) => vocab.id,
                        value: (vocab) => vocab['star'] ?? false,
                      );
                      print(_isClickedMap.values);
                      
                      return Container(
                        color: Colors.teal.shade200,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: vocabularies.length,
                          itemBuilder: (BuildContext context, int index) {
                            final vocabulary = vocabularies[index];
                            final String vocabId = vocabulary.id;
                            final String vocabularyName = vocabulary['term'];
                            final String vocabularyMeaning = vocabulary['definition'];
                            final List<dynamic> types = vocabulary['types'];
                            final bool isStar = vocabulary['star'] ?? false;
                            return _buildBoxForVocabulary(vocabularyName, vocabularyMeaning, types, vocabId, isStar, courseId);
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    ),
  );
}

Widget _buildBoxForVocabulary(String vocabularyName, String vocabularyMeaning, List<dynamic> types, String vocabId, bool isStar, String courseId) {
    var screenSize = MediaQuery.of(context).size;
    print(_isClickedMap[vocabId]);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all( 8.0),
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
                  children: types.map((type) => Chip(
                    label: Text(
                      type.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  )).toList(),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              print(vocabId);
              print(_isClickedMap[vocabId]);
              setState(() {
                _isClickedMap[vocabId] = !_isClickedMap[vocabId]!;
                _saveVocabStar(_isClickedMap[vocabId]!, vocabId, courseId);
              });
            },
            icon: isStar ? Icon(Icons.star_outlined) : Icon(Icons.star_border_outlined),
            iconSize: screenSize.width * 0.05,
            color: isStar ? Colors.amber : Colors.grey,
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
  Future<void> _saveVocabStar(bool isStar, String vocabId, String courseId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(courseId)
        .collection('vocabularies')
        .doc(vocabId)
        .update({'star': isStar});
  }
Stream<QuerySnapshot> _fetchDataCourse(String userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .snapshots();
}

Stream<QuerySnapshot> _fetchDataVocabularies(String userId, String courseId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)
      .collection('vocabularies')
      .where('star', isEqualTo: true)
      .snapshots();
}

}
