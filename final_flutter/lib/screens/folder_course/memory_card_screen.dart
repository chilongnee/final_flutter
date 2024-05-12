import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_flutter/home.dart';
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
  late Future<List<DocumentSnapshot>> _vocabularies;
  int _currentIndex = 0;
  CardSwiperController _swiperController = new CardSwiperController();

  @override
  void initState() {
    super.initState();
    _course = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .get();
    _vocabularies = _fetchVocabularies();
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
          preferredSize: Size.fromHeight(screenSize.height*0.001),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder(
              future: _vocabularies,
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  final totalVocabularies = snapshot.data!.length;
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
      body: FutureBuilder(
        future: _vocabularies,
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            final vocabularies = snapshot.data!;
            return Center(
              child: Container(
                color: Colors.teal.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenSize.height * 0.75,
                      child: CardSwiper(
                        controller: _swiperController,
                        isLoop: false,
                        cardBuilder: (context, index, percentThresholdX,
                            percentThresholdY) {
                          return _buildFlashCard(
                            vocabularies[index]['definition'] as String,
                            vocabularies[index]['term'] as String,
                            vocabularies[index]['types'] as List<dynamic>,
                          );
                        },
                        cardsCount: vocabularies.length,
                        
                        onSwipe: (prevIndex, currentIndex, direction) {
                          if(currentIndex == null){
                            Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Home()),
                          );
                          }
                          setState(() {
                            if(currentIndex != null){
                              _currentIndex = currentIndex + 1;
                            }
                          });
                          return true;
                        },
                      ),
                    ),
                    Row(
                      children: [
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            if (_currentIndex > 0) {
                              _swiperController.undo();
                              setState(() {
                                _currentIndex -= 1;
                              });
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
                            onPressed: (){
                              print("1");
                            },
                            icon: Icon(
                              Icons.play_arrow,
                              size: screenSize.width * 0.08,),
                          ),)
                      ]
                      
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFlashCard(
      String vocabularyName, String vocabularyMeaning, List<dynamic> types) {
    var screenSize = MediaQuery.of(context).size;
    return Card(
      child: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 32.0, bottom: 16),
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
            Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                vocabularyName,
                style: TextStyle(
                  fontSize: 45,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                vocabularyMeaning,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                types.toString(),
                style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Color.fromRGBO(108, 91, 214, 1)),
              ),
            ),
            IconButton(
                onPressed: _speaker,
                icon: Icon(
                  Icons.campaign,
                  size: screenSize.width * 0.1,
                ))
          ],
        ),
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

  void _speaker() {}
}
