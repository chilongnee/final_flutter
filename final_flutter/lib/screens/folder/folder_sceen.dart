import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Folder extends StatefulWidget {
  const Folder({super.key});

  @override
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Folder')),
      body: Container(
        color: const Color(0xFFBBEDF2),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
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
                        final List<DocumentSnapshot> folders =
                            snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: folders.length,
                              itemBuilder: (BuildContext context, int index) {
                                final folder = folders[index];
                                return Container(
                                  width: screenWidth,
                                  margin: const EdgeInsets.all(8.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            folder['description'],
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
