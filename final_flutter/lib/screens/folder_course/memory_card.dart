import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/home.dart';
import 'package:final_flutter/screens/folder_course/summarize_memory_card.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MemoryCardScreen extends StatefulWidget {
  final String courseId;
  final String userId;

  const MemoryCardScreen({
    Key? key,
    required this.userId,
    required this.courseId,
  }) : super(key: key);

  @override
  _MemoryCardScreenState createState() => _MemoryCardScreenState();
}

class _MemoryCardScreenState extends State<MemoryCardScreen> {
  late Future<DocumentSnapshot> _course;
  late Future<List<DocumentSnapshot>> _listVocab;
  late Stream<QuerySnapshot> _vocabulariesStream;
  late FlutterTts flutterTts = FlutterTts();
  bool _isStudied = false;
  int _currentIndex = 1;
  int _previousIndex = 1;
  int studyingCount = 0;
  int learnedCount = 0;
  CardSwiperController _swiperController = CardSwiperController();
  bool isBack = true;
  double angle = 0;
  bool _isAutoSpeak = false;
  int? _selectedIndexVoice = 1;
  int? _selectedIndexSide = 0;  
  bool _isBackSide = true;

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
                  final totalVocabularies = snapshot.data!.docs.where((doc) => doc['status'] == 'Đang học').length;
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
      body: _buildMemoryCardWidget(screenSize),
    );
  }

  Widget _buildMemoryCardWidget(Size screenSize) {
    return FutureBuilder(
      future: _listVocab,
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error');
        } else {
          final vocabularies = snapshot.data!
              .where((doc) => doc['status'] == 'Đang học')
              .toList();

          return _buildMemoryCardLayout(screenSize, vocabularies);
        }
      },
    );
  }

  Widget _buildMemoryCardLayout(
      Size screenSize, List<DocumentSnapshot> vocabularies) {
    isBack = true;

    return Center(
      child: Container(
        color: Colors.teal.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenSize.width * 0.15,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        color: Colors.orangeAccent.shade200,
                        border: Border(
                          top: BorderSide(width: 2.0, color: Colors.white),
                          bottom: BorderSide(width: 2.0, color: Colors.white),
                          left: BorderSide(width: 2.0, color: Colors.white),
                          right: BorderSide(width: 1.0, color: Colors.white),
                        )),
                    child: Text(
                      studyingCount.toString(),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: screenSize.width * 0.15,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        color: Colors.green,
                        border: Border(
                          top: BorderSide(width: 2.0, color: Colors.white),
                          bottom: BorderSide(width: 2.0, color: Colors.white),
                          left: BorderSide(width: 1.0, color: Colors.white),
                          right: BorderSide(width: 2.0, color: Colors.white),
                        )),
                    child: Text(
                      learnedCount.toString(),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.73,
              child: CardSwiper(
                controller: _swiperController,
                isLoop: false,
                numberOfCardsDisplayed: vocabularies.length > 2 ? 2 : 1,
                cardBuilder:
                    (context, index, percentThresholdX, percentThresholdY) {
                  return _buildFlashCard(
                    vocabularies[index]['definition'] as String,
                    vocabularies[index]['term'] as String,
                    vocabularies[index]['types'] as List<dynamic>,
                  );
                },
                onTapDisabled: _flip,
                cardsCount: vocabularies.length,
                onSwipe: (prevIndex, currentIndex, direction) {
                  if (prevIndex == vocabularies.length - 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SummarizeMemoryCard(
                            learnedCount: learnedCount,
                            studyingCount: studyingCount,
                            courseId: widget.courseId,
                            userId: widget.userId),
                      ),
                    );
                  }
                  if (direction == CardSwiperDirection.left) {
                    setState(() {
                      studyingCount += 1;
                    });
                    _isStudied = false;
                    final currentDocId = vocabularies[prevIndex ?? 1].id;
                    _saveVocabStatus(_isStudied, currentDocId);
                  }
                  if (direction == CardSwiperDirection.right) {
                    print("preS: $_previousIndex");
                    print("currentS: $_currentIndex");
                    setState(() {
                      learnedCount += 1;
                    });
                    _isStudied = true;
                    final currentDocId = vocabularies[prevIndex ?? 1].id;
                    _saveVocabStatus(_isStudied, currentDocId);
                  }
                  if (currentIndex != null) {
                    if (_isAutoSpeak) {
                      _speak(vocabularies[currentIndex]['term']);
                    }
                    setState(() {
                      _previousIndex = _currentIndex;
                      _currentIndex = currentIndex + 1;
                    });
                  }

                  return true;
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      if (_previousIndex != _currentIndex) {
                        print("pre: $_previousIndex");
                        print("index: $_currentIndex");
                        _swiperController.undo();
                        _swiperController.moveTo(_previousIndex - 1);
                        setState(() {
                          _currentIndex = _previousIndex;
                          if (learnedCount > 0) {
                            learnedCount -= 1;
                          }
                        });
                        print("pre2: $_previousIndex");
                        print("index2: $_currentIndex");
                      }
                    },
                    icon: Icon(
                      Icons.keyboard_return,
                      size: screenSize.width * 0.08,
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      print("index: $_currentIndex");
                      if (_previousIndex <= vocabularies.length) {
                        _previousIndex = _currentIndex;
                        print("pre: $_previousIndex");
                        _swiperController.moveTo(_currentIndex);

                        setState(() {
                          learnedCount += 1;
                          _currentIndex += 1;
                        });
                        print("index2: $_currentIndex");
                      }
                      print("index3: $_currentIndex");
                      print("pre3: $_previousIndex");
                      if (_previousIndex == vocabularies.length) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SummarizeMemoryCard(
                                learnedCount: learnedCount,
                                studyingCount: studyingCount,
                                courseId: widget.courseId,
                                userId: widget.userId),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      size: screenSize.width * 0.08,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashCard(
      String vocabularyMeaning, String vocabularyName, List<dynamic> types) {
    var screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _flip,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: angle),
        duration: Duration(seconds: 1),
        builder: (BuildContext context, double val, __) {
          if (val >= (pi / 2) && val < (3 * pi / 2)) {
            isBack = false;
          } else {
            isBack = true;
          }
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(isBack ? val : pi - val),
            child: Container(
                width: screenSize.width * 0.9,
                height: screenSize.height * 0.6,
                child: _isBackSide
                    ? isBack
                        ? _buildFrontCardContent(
                            vocabularyName, vocabularyMeaning, types)
                        : _buildBackCardContent(vocabularyMeaning)
                    : isBack
                        ? _buildBackCardContent(vocabularyMeaning)
                        : _buildFrontCardContent(
                            vocabularyName, vocabularyMeaning, types)),
          );
        },
      ),
    );
  }

  Widget _buildFrontCardContent(
      String vocabularyName, String vocabularyMeaning, List<dynamic> types) {
    var screenSize = MediaQuery.of(context).size;
    print("speak $_isAutoSpeak");

    return Card(
      margin: EdgeInsets.only(
          left: screenSize.width * 0.05, right: screenSize.width * 0.05),
      child: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: screenSize.width * 0.1, bottom: screenSize.width * 0.05),
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
    );
  }

  Widget _buildBackCardContent(String vocabularyMeaning) {
    var screenSize = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.only(
          left: screenSize.width * 0.05, right: screenSize.width * 0.05),
      child: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: screenSize.width * 0.1, bottom: screenSize.width * 0.05),
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
            SizedBox(height: screenSize.height * 0.01),
            Text(
              vocabularyMeaning,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.height * 0.01),
          ],
        ),
      ),
    );
  }

  void _flip() {
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
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
                    child: Text('Tự động phát bản thu',style: TextStyle(fontSize: 15)),
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
                      initialLabelIndex: _selectedIndexVoice,
                      totalSwitches: 2,
                      labels: ['ON', 'OFF'],
                      radiusStyle: true,
                      onToggle: (index) async {
                        setState(() {
                          _isAutoSpeak = !_isAutoSpeak;
                          _selectedIndexVoice = index;
                        });
                        if (_isAutoSpeak) {
                          if (_listVocab != null) {
                            final List<DocumentSnapshot> vocabularies =
                                await _listVocab;
                            if (_currentIndex <= vocabularies.length) {
                              _speak(vocabularies[_currentIndex - 1]['term']);
                            }
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
              Text(
                'Thiết lập thẻ nhớ mặt trước',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              Padding(
                padding: EdgeInsets.only(top: screenSize.width * 0.04),
                child: ToggleSwitch(
                  minWidth: screenSize.width * 0.5,
                  initialLabelIndex: _selectedIndexSide,
                  totalSwitches: 2,
                  labels: ['Thuật ngữ', 'Đinh nghĩa'],
                  customTextStyles: [
                    TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  ],
                  activeBgColor: [Colors.teal.shade300],
                  inactiveBgColor: Colors.white,
                  inactiveFgColor: Colors.teal.shade300,

                  onToggle: (index) {
                    if(index == 1){
                      setState(() {
                        _selectedIndexSide = 1;
                        _isBackSide = false;
                      });
                    }else if (index == 0){
                      setState(() {
                        _selectedIndexSide = 0;
                        _isBackSide = true;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
