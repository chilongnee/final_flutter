import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/home.dart';
import 'package:final_flutter/screens/folder_course/memory_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SummarizeMemoryCard extends StatefulWidget {
  final String courseId;
  final String userId;
  final int studyingCount;
  final int learnedCount;
  const SummarizeMemoryCard({
    Key? key,
    required this.studyingCount,
    required this.learnedCount,
    required this.userId,
    required this.courseId,
  }) : super(key: key);

  @override
  _SummarizeMemoryCardScreenState createState() =>
      _SummarizeMemoryCardScreenState();
}

class _SummarizeMemoryCardScreenState extends State<SummarizeMemoryCard> {
  late Future<DocumentSnapshot> _course;
  late Stream<QuerySnapshot> _vocabulariesStream;

  @override
  void initState() {
    super.initState();
    _course = _fetchCourses();
    _vocabulariesStream = _fetchVocabularies();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
              stream: _vocabulariesStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  final totalVocabularies = snapshot.data!.docs.where((doc) => doc['status'] == 'Đang học').length;
                  return Text(
                    '${totalVocabularies}/$totalVocabularies',
                    style: TextStyle(fontSize: 24.0, color: Colors.black),
                  );
                }
              },
            ),
        centerTitle: true,
        
      ),
      body: StreamBuilder(
        stream: _vocabulariesStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            final vocabularies = snapshot.data!.docs;
            final knownCount = widget.learnedCount;
            final learningCount = widget.studyingCount;
            final totalVocabularies = knownCount + learningCount;

            return Center(
              child: Container(
                color: Colors.teal.shade200,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.09,
                            horizontal: screenSize.width * 0.09),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Bạn đã học rất tốt! Hãy tiếp tục phát huy nhé',
                                style: const TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.08),
                            Container(
                              width: screenSize.width * 0.25,
                              height: screenSize.width * 0.25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                image: DecorationImage(
                                  image: AssetImage('assets/image_congrat.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenSize.height * 0.02,
                          horizontal: screenSize.width * 0.09,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: CircularPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                animateFromLastPercent: false,
                                radius: screenSize.width * 0.18,
                                lineWidth: 15,
                                percent: knownCount / totalVocabularies,
                                progressColor: Colors.green,
                                backgroundColor: Colors.orangeAccent.shade200,
                                circularStrokeCap: CircularStrokeCap.round,
                                center: Text(
                                  '${(knownCount / totalVocabularies * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.1),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Đã biết',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.green
                                      ),
                                    ),
                                    SizedBox(width: screenSize.width * 0.2),
                                    CircularPercentIndicator(
                                      radius: 20,
                                      center: Text(
                                        '$knownCount',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenSize.height * 0.05),
                                Row(
                                  children: [
                                    Text(
                                      'Đang học',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.orangeAccent.shade200,
                                      ),
                                    ),
                                    SizedBox(width: screenSize.width * 0.15),
                                    CircularPercentIndicator(
                                      radius: 20,
                                      center: Text(
                                        '$learningCount',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      backgroundColor:
                                          Colors.orangeAccent.shade200,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.075),
                      Column(
                        children: [
                          if (learningCount > 0)
                            SizedBox(
                              width: screenSize.width * 0.85,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Tiếp tục ôn $learningCount thuật ngữ',
                                  style: TextStyle(
                                    color: Colors.teal.shade600,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: () {
                                  
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MemoryCardScreen(
                                              userId: widget.userId,
                                              courseId: widget.courseId,
                                            )),
                                  );
                                },
                              ),
                            ),
                          SizedBox(
                              height: screenSize.height *0.01),
                          SizedBox(
                            width: screenSize.width * 0.85,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Ôn trong chế độ Học',
                                style: TextStyle(
                                  color: Colors.teal.shade600,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                          
                          SizedBox(
                              height: screenSize.height *0.01),
                          SizedBox(
                            width: screenSize.width * 0.85,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Đặt lại thẻ ghi nhớ',
                                style: TextStyle(
                                  color: Colors.teal.shade600,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {
                                _resetVocabStatus();
                                
                              },
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
            );
          }
        },
      ),
    );
  }

  Stream<QuerySnapshot> _fetchVocabularies() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .snapshots();
  }

  Future<DocumentSnapshot> _fetchCourses() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .get();
  }
  Future<void> _resetVocabStatus() async {
  final CollectionReference vocabulariesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .collection('courses')
      .doc(widget.courseId)
      .collection('vocabularies');

  final QuerySnapshot querySnapshot = await vocabulariesCollection.get();

  for (var doc in querySnapshot.docs) {
    await vocabulariesCollection.doc(doc.id).update({'status': 'Đang học'});
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MemoryCardScreen(
              userId: widget.userId, courseId: widget.courseId)),
    );
}

  
}
