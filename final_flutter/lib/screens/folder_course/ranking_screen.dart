import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RankingScreen extends StatefulWidget {
  final String courseId;
  final String userId;

  const RankingScreen({required this.userId, required this.courseId, super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<DocumentSnapshot> _course;
  late Future<List<Map<String, dynamic>>> _rankingListFuture;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _course = _fetchCourses();
    _rankingListFuture = _fetchAndSortRanking();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: _course,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
      body: FutureBuilder(
          future: _rankingListFuture,
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No rankings available');
            } else {
              final List<Map<String, dynamic>> rankingList = snapshot.data!;
              final rank = rankingList.where((doc) => doc['userId'] == user!.uid).toList();
              var getRanking = rank.isNotEmpty ? rank[0] : {};
              var totalRight = getRanking['totalRight'] ?? '0/0';
              var ranked = getRanking['ranked'] ?? '-';
              return _buildRankingWidget(screenSize, totalRight, ranked, rankingList);
            }
          }),
    );
  }

  Widget _buildRankingWidget(
      Size screenSize, dynamic totalRight, dynamic ranked, List<Map<String, dynamic>> rankingList) {
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
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  if (index < rankingList.length) {
                    return _buildRankingItem(screenSize, rankingList[index], index + 1);
                  } else {
                    return _buildDefaultRankingItem(screenSize, index + 1);
                  }
                },
              ),
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

  Future<List<Map<String, dynamic>>> _fetchAndSortRanking() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('ranking')
        .get();

    if (snapshot.docs.isNotEmpty) {
      List<QueryDocumentSnapshot> rankingDocs = snapshot.docs;

      rankingDocs.sort((a, b) {
        List<String> partsA = a['totalRight'].split('/');
        List<String> partsB = b['totalRight'].split('/');
        int totalRightA = int.parse(partsA[0]);
        int totalRightB = int.parse(partsB[0]);
        return totalRightB.compareTo(totalRightA);
      });

      for (int i = 0; i < rankingDocs.length; i++) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('courses')
            .doc(widget.courseId)
            .collection('ranking')
            .doc(rankingDocs[i].id)
            .update({'ranked': i + 1});
      }

      List<Future<Map<String, dynamic>>> rankingFutures = rankingDocs.map((doc) async {
        String userId = doc['userId'];
        int ranked = doc['ranked'];
        String totalRight = doc['totalRight'];
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        return {
          'userId': userId,
          'ranked': ranked,
          'totalRight': totalRight,
          'userName': userSnapshot['userName'],
        };
      }).toList();

      // Chờ tất cả các Future hoàn thành
      List<Map<String, dynamic>> rankingList = await Future.wait(rankingFutures);
      return rankingList;
    } else {
      return [];
    }
  }

  Widget _buildRankingItem(Size screenSize, Map<String, dynamic> user, int rank) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
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
              rank.toString(),
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 153, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/avtUser.png',
              width: screenSize.width * 0.3,
              height: screenSize.height * 0.2,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              user['userName'],
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 153, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              user['totalRight'],
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

  Widget _buildDefaultRankingItem(Size screenSize, int rank) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
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
              rank.toString(),
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 153, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/avtUser.png',
              width: screenSize.width * 0.3,
              height: screenSize.height * 0.2,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Trống',
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 153, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '0/0',
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
