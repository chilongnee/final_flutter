  import 'dart:math';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:final_flutter/home.dart';
  import 'package:final_flutter/screens/folder_course/summarize_memory_card.dart';
  import 'package:flutter_card_swiper/flutter_card_swiper.dart';
  import 'package:flutter/material.dart';

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
    bool _isStudied = false;
    int _currentIndex = 1;
    int _previousIndex = 1;
    int studyingCount = 0;
    int learnedCount = 0;
    CardSwiperController _swiperController = CardSwiperController();
    bool isBack = true;
    double angle = 0;
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
                            bottom:
                                BorderSide(width: 2.0, color: Colors.white),
                            left: BorderSide(width: 2.0, color: Colors.white),
                            right: BorderSide(width: 1.0, color: Colors.white),
                          )),
                      child: Text(
                        studyingCount.toString(),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color:Colors.white,
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
                            bottom:
                                BorderSide(width: 2.0, color: Colors.white),
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
                  cardBuilder: (context, index, percentThresholdX,
                      percentThresholdY) {
                        
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
                      _swiperController.moveTo(_previousIndex-1);
                      setState(() {
                        _currentIndex = _previousIndex;
                        if(learnedCount >0){
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
                    if (_previousIndex == vocabularies.length  ) {
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

    Widget _buildFlashCard(String vocabularyMeaning, String vocabularyName,  List<dynamic> types) {
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
              child: isBack
                  ? _buildFrontCardContent(vocabularyName, vocabularyMeaning, types)
                  : _buildBackCardContent(vocabularyMeaning),
            ),
          );
        },
      ),
    );
  }


  Widget _buildFrontCardContent(String vocabularyName, String vocabularyMeaning, List<dynamic> types) {
    var screenSize = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.only(left: screenSize.width * 0.05, right:screenSize.width * 0.05),
      child: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: screenSize.width * 0.1, bottom: screenSize.width * 0.05),
              width: screenSize.width * 0.5,
              height: screenSize.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: const DecorationImage(
                  image: NetworkImage('https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/15171524/image-188-hinh-anh-con-vit-trang-vang-cute-ngau-ban-nen-xem-167643092454557.jpg'),
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
              onPressed: () => _speaker(),
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
      margin: EdgeInsets.only(left: screenSize.width * 0.05, right:screenSize.width * 0.05),
      child: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: screenSize.width * 0.1, bottom: screenSize.width * 0.05),
              width: screenSize.width * 0.5,
              height: screenSize.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: const DecorationImage(
                  image: NetworkImage('https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/15171524/image-188-hinh-anh-con-vit-trang-vang-cute-ngau-ban-nen-xem-167643092454557.jpg'),
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
    void _speaker() {
    }

    

    

  }

