import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/home.dart';
import 'package:final_flutter/screens/folder_course/sumarize_test.dart';
import 'package:final_flutter/screens/folder_course/summarize_memory_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:toggle_switch/toggle_switch.dart';

class QuizTest extends StatefulWidget {
  final String courseId;
  final String userId;

  const QuizTest({
    Key? key,
    required this.userId,
    required this.courseId,
  }) : super(key: key);

  @override
  _QuizTestState createState() => _QuizTestState();
}

class _QuizTestState extends State<QuizTest> {
  late Future<DocumentSnapshot> _course;
  late Future<List<DocumentSnapshot>> _listVocab;
  late Stream<QuerySnapshot> _vocabulariesStream;
  late FlutterTts flutterTts = FlutterTts();
  int _currentIndex = 1;
  bool _isCorrect = false;
  bool _isCorrect2 = false;
  bool _isCorrect3 = false;
  bool _isCorrect4 = false;
  bool _isFalse = false;
  bool _isFalse2 = false;
  bool _isFalse3 = false;
  bool _isFalse4 = false;
  int resultOfTest = 0;
  DocumentSnapshot? _currentVocabulary;
  List<String> _answers = [];
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

            if(_answers.isEmpty){
              if (eng_vi == true) {
                _answers = _generateAnswerChoicesEn(vocabularies, vocabularyName);
              }else{
                _answers = _generateAnswerChoicesVi(vocabularies, vocabularyMeaning);

              }
            }
            if (eng_vi == true) {
              return _buildQuizLayout(screenSize, vocabularyMeaning,
                  vocabularyName, types, _answers);
            }
            return _buildQuizLayout(
                screenSize, vocabularyName, vocabularyMeaning, types, _answers);

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
      String vocabularyMeaning, List<dynamic> types, List<String> answers) {
    return Container(
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
            child: Container(
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    if (answers[0] == vocabularyMeaning) {
                      setState(() {
                        _isCorrect = true;
                        resultOfTest = resultOfTest + 1;
                      });
                    } else if (answers[0] != vocabularyMeaning) {
                      setState(() {
                        _isFalse = true;
                      });
                    }

                    _delayAndNextQuestion();
                  },
                  child: Container(
                    width: screenSize.width * 0.4,
                    height: screenSize.height * 0.06,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: _isFalse
                            ? Colors.red
                            : _isCorrect
                                ? Colors.green
                                : Colors.white),
                    child: Center(
                      child: Text(
                        'A. ${answers[0]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (answers[1] == vocabularyMeaning) {
                      setState(() {
                        _isCorrect2 = true;
                        resultOfTest = resultOfTest + 1;
                      });
                    } else if (answers[1] != vocabularyMeaning) {
                      setState(() {
                        _isFalse2 = true;
                      });
                    }
                    _delayAndNextQuestion();
                  },
                  child: Container(
                    width: screenSize.width * 0.4,
                    height: screenSize.height * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: _isFalse2
                          ? Colors.red
                          : _isCorrect2
                              ? Colors.green
                              : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        'B. ${answers[1]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  if (answers[2] == vocabularyMeaning) {
                    setState(() {
                      _isCorrect3 = true;
                      resultOfTest = resultOfTest + 1;
                    });
                  } else if (answers[2] != vocabularyMeaning) {
                    setState(() {
                      _isFalse3 = true;
                    });
                  }
                  _delayAndNextQuestion();
                },
                child: Container(
                  width: screenSize.width * 0.4,
                  height: screenSize.height * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: _isFalse3
                        ? Colors.red
                        : _isCorrect3
                            ? Colors.green
                            : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'C. ${answers[2]}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              if (answers.length > 3)
                GestureDetector(
                  onTap: () {
                    if (answers[3] == vocabularyMeaning) {
                      setState(() {
                        _isCorrect4 = true;
                        resultOfTest = resultOfTest + 1;
                      });
                    } else if (answers[3] != vocabularyMeaning) {
                      setState(() {
                        _isFalse4 = true;
                      });
                    }
                    _delayAndNextQuestion();
                  },
                  child: Container(
                    width: screenSize.width * 0.4,
                    height: screenSize.height * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: _isFalse4
                          ? Colors.red
                          : _isCorrect4
                              ? Colors.green
                              : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        'D. ${answers[3]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          )
        ],
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
                            _answers = [];
                            eng_vi = false;
                            _selectedLanguage = 1;
                          }
                          else if(index == 0){
                            _answers = [];
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

  Future<void> _saveVocabStatus(bool isStudied, String vocabId) async {
    String status = isStudied ? 'Đã biết' : 'Đang học';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .doc(vocabId)
        .update({'status': status});
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  List<int> generateRandomNumbers(int min, int max, int count) {
    if (max <= min || count <= 0 || count > (max - min + 1)) {
      print("Invalid range or count");
    }

    Random random = Random();
    List<int> randomNumbers = [];

    while (randomNumbers.length < count) {
      int randomNumber = min + random.nextInt(max - min + 1);
      if (!randomNumbers.contains(randomNumber)) {
        randomNumbers.add(randomNumber);
      }
    }

    return randomNumbers;
  }

  List<int> getTotalAnswer(List<DocumentSnapshot<Object?>> vocabularies) {
    List<int> randomNumbers = [];
    if (vocabularies.length != 3) {
      randomNumbers = generateRandomNumbers(0, vocabularies.length - 1, 4);
    } else {
      randomNumbers = generateRandomNumbers(0, vocabularies.length - 1, 3);
    }
    return randomNumbers;
  }

  List<String> _generateAnswerChoicesVi(
      List<DocumentSnapshot> vocabularies, String correctAnswer) {
    final randomIndicesVi = getTotalAnswer(vocabularies);

    if (!randomIndicesVi.contains(_currentIndex - 1)) {
      randomIndicesVi[Random().nextInt(3)] = _currentIndex - 1;
    }

    final answersVi = randomIndicesVi.map((index) {
      return vocabularies[index]['definition'].toString();
    }).toList();

    answersVi.shuffle();

    return answersVi;
  }
  List<String> _generateAnswerChoicesEn(
      List<DocumentSnapshot> vocabularies, String correctAnswer) {
    final randomIndices = getTotalAnswer(vocabularies);

    if (!randomIndices.contains(_currentIndex - 1)) {
      randomIndices[Random().nextInt(3)] = _currentIndex - 1;
    }

    final answers = randomIndices.map((index) {
      return vocabularies[index]['term'].toString();
    }).toList();

    answers.shuffle();

    return answers;
  }

  Future<void> _delayAndNextQuestion() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _currentIndex++;
      _isCorrect = false;
      _isCorrect2 = false;
      _isCorrect3 = false;
      _isCorrect4 = false;
      _isFalse = false;
      _isFalse2 = false;
      _isFalse3 = false;
      _isFalse4 = false;
      _currentVocabulary = null; 
      _answers = []; 
    });
  }

  
}
