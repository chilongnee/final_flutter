import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/screens/folder_course/sumarize_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:toggle_switch/toggle_switch.dart';

class TypeTest extends StatefulWidget {
  final String courseId;
  final String userId;

  const TypeTest({
    Key? key,
    required this.userId,
    required this.courseId,
  }) : super(key: key);

  @override
  _TypeTestState createState() => _TypeTestState();
}

class _TypeTestState extends State<TypeTest> {
  late Future<DocumentSnapshot> _course;
  late Future<List<DocumentSnapshot>> _listVocab;
  late Stream<QuerySnapshot> _vocabulariesStream;
  late FlutterTts flutterTts = FlutterTts();
  int _currentIndex = 1;
  int resultOfTest = 0;
  DocumentSnapshot? _currentVocabulary;
  String _userAnswer = '';
  TextEditingController _textEditingController = TextEditingController();
  bool eng_vi = false;
  int? _selectedLanguage = 1;
  @override
  void initState() {
    super.initState();
    _course = _fetchCourses();
    _listVocab = _fetchListVocabularies();
    _vocabulariesStream = _fetchVocabularies();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: _course,
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
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenSize.height * 0.001),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _vocabulariesStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  final totalVocabularies = snapshot.data!.docs.length;
                  return Text(
                    '${_currentIndex}/$totalVocabularies',
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  );
                }
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingBottomSheet(context),
          ),
        ],
      ),
      body: _buildQuizWidget(screenSize),
    );
  }

  Widget _buildQuizWidget(Size screenSize) {
    return FutureBuilder(
      future: _listVocab,
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else {
          final vocabularies = snapshot.data!;

          if (_currentIndex - 1 < vocabularies.length) {
            _currentVocabulary = vocabularies[_currentIndex - 1];
            final String vocabularyName = _currentVocabulary!['term'];
            final String vocabularyMeaning = _currentVocabulary!['definition'];
            final List<dynamic> types = _currentVocabulary!['types'];
            if (eng_vi == true) {
              return _buildQuizLayout(
                  screenSize, vocabularyMeaning, vocabularyName, types);
            }
            return _buildQuizLayout(
                screenSize, vocabularyName, vocabularyMeaning, types);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SummarizeTest(
                    courseId: widget.courseId,
                    userId: widget.userId,
                    result: resultOfTest,
                    totalVocab: vocabularies,
                  ),
                ),
              );
            });

            return Container();
          }
        }
      },
    );
  }

  Widget _buildQuizLayout(Size screenSize, String vocabularyName,
      String vocabularyMeaning, List<dynamic> types) {
    return SingleChildScrollView(
      child: Container(
        height: screenSize.height,
        width: screenSize.width,
        color: Colors.teal.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 84, right: 84),
              margin: EdgeInsets.only(bottom: screenSize.height * 0.05),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: screenSize.width * 0.1,
                        bottom: screenSize.width * 0.05),
                    width: screenSize.width * 0.5,
                    height: screenSize.height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/15171524/image-188-hinh-anh-con-vit-trang-vang-cute-ngau-ban-nen-xem-167643092454557.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    vocabularyName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    types.join(', '),
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Color.fromRGBO(108, 91, 214, 1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    onPressed: () => _speak(vocabularyName),
                    icon: Icon(
                      Icons.campaign,
                      size: screenSize.width * 0.1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      onChanged: (value) {
                        setState(() {
                          _userAnswer = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Your Answer',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  _userAnswer.isEmpty
                      ? TextButton(
                          onPressed: () {
                            _checkAnswer(vocabularyName, vocabularyMeaning);
                          },
                          child: Text('Không biết'),
                        )
                      : IconButton(
                          onPressed: () {
                            _checkAnswer(vocabularyName, vocabularyMeaning);
                          },
                          icon: Icon(Icons.check, color: Colors.green),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
void _showSettingBottomSheet(BuildContext context) async {
    var screenSize = MediaQuery.of(context).size;
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Hỏi bằng tiếng Việt, trả lời bằng tiếng Anh',style: TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    child: ToggleSwitch(
                      minWidth: screenSize.width * 0.28,
                      cornerRadius: 20.0,
                      activeBgColors: [
                        [Colors.green[800]!],
                        [Colors.red[800]!]
                      ],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      initialLabelIndex: _selectedLanguage,
                      totalSwitches: 2,
                      labels: ['ON', 'OFF'],
                      radiusStyle: true,
                      onToggle: (index)  {
                        setState(() {

                          if(index == 1){
                            eng_vi = false;
                            _selectedLanguage = 1;
                          }
                          else if(index == 0){
                            eng_vi = true;
                            _selectedLanguage = 0;
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  Future<DocumentSnapshot> _fetchCourses() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .get();
  }

  Future<List<DocumentSnapshot>> _fetchListVocabularies() async {
    final QuerySnapshot vocabularySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .get();
    return vocabularySnapshot.docs;
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

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  void _checkAnswer(String vocabularyName, String correctAnswer) {
    bool isCorrect =
        _userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var screenSize = MediaQuery.of(context).size;
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              color: isCorrect ? Colors.green : Colors.red,
            ),
            child: Text(
              isCorrect ? 'Correct!' : 'Incorrect',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          content: isCorrect
              ? Text(
                  '$vocabularyName - $correctAnswer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$vocabularyName - $correctAnswer',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Text('Đáp án đúng:',
                        style: TextStyle(fontSize: 15, color: Colors.green)),
                    SizedBox(height: screenSize.height * 0.008),
                    Text('$correctAnswer', style: TextStyle(fontSize: 15)),
                    SizedBox(height: screenSize.height * 0.01),
                    Text('Đáp án bạn chọn:',
                        style: TextStyle(fontSize: 15, color: Colors.red)),
                    SizedBox(height: screenSize.height * 0.008),
                    Text('$_userAnswer', style: TextStyle(fontSize: 15)),
                  ],
                ),
          actions: [
            Center(
              child: TextButton(
                child: Text('Tiếp tục'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _delayAndNextQuestion();
                },
              ),
            ),
          ],
        );
      },
    );
    if (isCorrect) {
      setState(() {
        resultOfTest++;
      });
    }
  }

  Future<void> _delayAndNextQuestion() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _currentIndex++;
      _userAnswer = '';
      _textEditingController.clear();
    });
  }
}
