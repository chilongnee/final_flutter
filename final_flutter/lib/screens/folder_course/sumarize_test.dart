import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/home.dart';
import 'package:final_flutter/screens/folder_course/course_detail.dart';
import 'package:final_flutter/screens/folder_course/memory_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SummarizeTest extends StatefulWidget {
  final String courseId;
  final String userId;
  final int result;
  final List<DocumentSnapshot<Object?>> totalVocab;

  const SummarizeTest({
    Key? key,
    required this.userId,
    required this.courseId,
    required this.result,
    required this.totalVocab,
  }) : super(key: key);

  @override
  _SummarizeTestScreenState createState() => _SummarizeTestScreenState();
}

class _SummarizeTestScreenState extends State<SummarizeTest> {
  late Future<DocumentSnapshot> _course;
  late Stream<QuerySnapshot> _vocabulariesStream;

  @override
  void initState() {
    super.initState();
    _course = _fetchCourses();
    _vocabulariesStream = _fetchVocabularies();
    bool _processingCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: _vocabulariesStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              final totalVocabularies = snapshot.data!.docs
                  .where((doc) => doc['status'] == 'Đang học')
                  .length;
              return Text(
                '${totalVocabularies}/$totalVocabularies',
                style: TextStyle(fontSize: 24.0, color: Colors.black),
              );
            }
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: _vocabulariesStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              final vocabularies = snapshot.data!.docs;
              bool _processingCompleted = false;
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
                            horizontal: screenSize.width * 0.05,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CircularPercentIndicator(
                                  animation: true,
                                  animationDuration: 1000,
                                  animateFromLastPercent: false,
                                  radius: screenSize.width * 0.18,
                                  lineWidth: 15,
                                  percent:
                                      widget.result / widget.totalVocab.length,
                                  progressColor: Colors.green,
                                  backgroundColor: Colors.orangeAccent.shade200,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  center: Text(
                                    '${(widget.result / widget.totalVocab.length * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(width: screenSize.width * 0.15),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Số câu đúng:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.green),
                                        ),
                                        SizedBox(width: screenSize.width * 0.03),
                                        CircularPercentIndicator(
                                          radius: 20,
                                          center: Text(
                                            widget.result.toString(),
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
                                          'Số câu sai:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.orangeAccent.shade200,
                                          ),
                                        ),
                                        SizedBox(width: screenSize.width * 0.085),
                                        CircularPercentIndicator(
                                          radius: 20,
                                          center: Text(
                                            (widget.totalVocab.length -
                                                    widget.result)
                                                .toString(),
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
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.18),
                        SizedBox(
                          width: screenSize.width * 0.85,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Quay lại học phần',
                              style: TextStyle(
                                color: Colors.teal.shade600,
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(
                          width: screenSize.width * 0.85,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Tiếp tục',
                              style: TextStyle(
                                color: Colors.teal.shade600,
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                        StreamBuilder(
                            stream: _fetchRanking(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (_processingCompleted) {
                                return Container();
                              } else {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Text('Error');
                                } else {
                                  List<int> lstTotalRight = [];
                                  var rankOfCurrent = 0;
                                  final rank = snapshot.data!.docs.toList();
                                  if (rank.length == 0) {
                                    int res = widget.result;
                                    int totalQuestion = widget.totalVocab.length;
                                    var totalR = '$res/$totalQuestion';
                                    addRanking({
                                      'userId': widget.userId,
                                      'ranked': rankOfCurrent + 1,
                                      'totalRight': totalR,
                                    });
                                  } else {
                                    for (int i = 0; i < rank.length; i++) {
                                      var data =
                                          rank[i].data() as Map<String, dynamic>;
                                      List<String> parts =
                                          data['totalRight'].split('/');
                                      int number = int.parse(parts[0]);
                                      lstTotalRight.add(number);
                                    }
                                    bool isAdd = true;
                                    bool isDelete = false;
                                    for (int i = 0; i < rank.length; i++) {
                                      var data =
                                          rank[i].data() as Map<String, dynamic>;
                                      List<String> parts =
                                          data['totalRight'].split('/');
                                      int number = int.parse(parts[0]);
                                      if (data['userId'] == widget.userId &&
                                          number <= widget.result) {
                                        isDelete = true;
                                      } else if (data['userId'] ==
                                              widget.userId &&
                                          number > widget.result) {
                                        isAdd = false;
                                      }
                                    }
                                    if (isDelete == true) {
                                      deleteDocumentByUserId(widget.userId);
                                    }
                                    if (isAdd == true) {
                                      lstTotalRight.sort();
                                      rankOfCurrent = addNumberAndGetIndex(
                                              lstTotalRight, widget.result) +
                                          1;
                                      int res = widget.result;
                                      int totalQuestion =
                                          widget.totalVocab.length;
                                      var totalR = '$res/$totalQuestion';
                                      addRanking({
                                        'userId': widget.userId,
                                        'ranked': rankOfCurrent,
                                        'totalRight': totalR,
                                      });
                                    }
                                    _processingCompleted = true;
                                  }
        
                                  return SizedBox();
                                }
                              }
                            }),
                      ]),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _fetchRanking() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('ranking')
        .snapshots();
  }

  Future<void> addRanking(Map<String, dynamic> rankingData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('ranking')
        .add(rankingData);
  }

  Future<void> deleteDocumentByUserId(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('ranking')
        .get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
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

  int addNumberAndGetIndex(List<int> sortedList, int number) {
    int index = 0;
    while (index < sortedList.length && sortedList[index] < number) {
      index++;
    }
    sortedList.insert(index, number);
    return index;
  }

  Future<void> _resetVocabStatus() async {
    final CollectionReference vocabulariesCollection = FirebaseFirestore
        .instance
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
