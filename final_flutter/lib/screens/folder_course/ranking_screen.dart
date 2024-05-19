import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RankingScreen extends StatefulWidget {
  final String courseId;
  final String userId;

  const RankingScreen(
      {required this.userId, required this.courseId, super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<DocumentSnapshot> _course;
  late Stream<QuerySnapshot> _ranking;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _course = _fetchCourses();
    _ranking = _fetchRanking();
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
            child: Text(
              'Xếp hạng',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )),
      ),
      body: StreamBuilder(
          stream: _ranking,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              final rank = snapshot.data!.docs
                  .where((doc) => doc['userId'] == widget.userId)
                  .toList();
              var getRanking = rank[0].data() as Map<String, dynamic>;
              var totalRight = getRanking['totalRight'];
              var ranked = getRanking['ranked'];
              return _buildRankingWidget(screenSize, totalRight, ranked);
            }
          }),
      //body: _buildRankingWidget(screenSize),
    );
  }

  Widget _buildRankingWidget(
      Size screenSize, dynamic totalRight, dynamic ranked) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.teal.shade200,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: screenSize.width * 0.05,
                    top: screenSize.height * 0.01),
                child: Row(
                  children: [
                    Image.asset('assets/ranking.png',
                        width: screenSize.width * 0.1),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Text(
                        'Điểm xếp hạng của bạn: $totalRight',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
              _buildListUser(screenSize),
              _buildListUser(screenSize),
              _buildListUser(screenSize),
              _buildListUser(screenSize),
              _buildListUser(screenSize),
              _buildListUser(screenSize),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: screenSize.width,
                height: screenSize.height * 0.15,
                color: Colors.teal.shade100,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Text(
                        'BẠN ĐANG Ở VỊ TRÍ THỨ $ranked',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.red.shade700),
                      ),
                    ),
                    SizedBox(
                      width: screenSize.width * 0.9,
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
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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

  Stream<QuerySnapshot> _fetchRanking() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('ranking')
        .snapshots();
  }

  Widget _buildListUser(Size screenSize) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
      ),
      padding: EdgeInsets.all(16),
      height: screenSize.height * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '01',
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 153, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/avtUser.png',
              width: screenSize.width * 0.3,
              height: screenSize.height * 0.2,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Username',
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 153, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '0000',
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 153, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
