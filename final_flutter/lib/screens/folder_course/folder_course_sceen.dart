import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'folder_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Folder extends StatefulWidget {
  const Folder({super.key});

  @override
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            title: const Text(
              'Thư viện',
              style: TextStyle(fontSize: 20.0),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: SizedBox(
                width: screenWidth,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(
                        child: Text(
                          'Học Phần',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Thư Mục',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                    tabAlignment: TabAlignment.start,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFFBBEDF2),
          child: TabBarView(
            children: [
              _buildCourseTab(screenWidth),
              _buildFolderTab(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderTab(double screenWidth) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot);
          return const Center(child: Text('Error'));
        } else {
          final List<DocumentSnapshot> users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .collection('folders')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error'));
                  } else {
                    final List<DocumentSnapshot> folders = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: folders.length,
                      itemBuilder: (BuildContext context, int index) {
                        final folder = folders[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FolderDetail(
                                  folderId: folder.id,
                                  userId: user.id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: screenWidth,
                            margin: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  folder['title'],
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  folder['username'],
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                if (folder['description'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      folder['description'],
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Future<User?> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getUsersByUsername(String userID) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID)
        .get();
    return userSnapshot.docs;
  }

  Widget _buildCourseTab(double screenWidth) {
    return FutureBuilder<User?>(
      future: getCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot<User?> userSnapshot) {
        final User? user = userSnapshot.data;
        if (user != null) {
          String currentUserID = user.uid ?? '';

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('userID', isEqualTo: currentUserID)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error'));
              } else {
                final List<DocumentSnapshot> users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return const Center(child: Text('Không tìm thấy người dùng'));
                } else {
                  final userId = users[0].id;
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('courses')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error'));
                      } else {
                        final List<DocumentSnapshot> courses =
                            snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: courses.length,
                          itemBuilder: (BuildContext context, int index) {
                            final course = courses[index];
                            return GestureDetector(
                              onTap: () {
                                print(courses[index].id);
                              },
                              child: Container(
                                width: screenWidth,
                                margin: const EdgeInsets.fromLTRB(
                                    20.0, 10.0, 20.0, 10.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course['title'],
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Progress: ${course['progress']}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                }
              }
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
