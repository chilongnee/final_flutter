import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FolderDetail extends StatefulWidget {
  final String userId;
  final String folderId;

  const FolderDetail({
    super.key,
    required this.userId,
    required this.folderId,
  });

  @override
  _FolderDetailState createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  late Future<DocumentSnapshot> _folderFuture;

  @override
  void initState() {
    super.initState();
    _folderFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('folders')
        .doc(widget.folderId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        // Sử dụng FutureBuilder để thiết lập tiêu đề của AppBar từ dữ liệu của folder
        title: FutureBuilder(
          future: _folderFuture,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else if (!snapshot.hasData) {
              return const Text('Folder not found');
            } else {
              final folderData = snapshot.data!;
              final String folderTitle = folderData['title'];
              return Text(folderTitle);
            }
          },
        ),
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: const Color(0xFFBBEDF2),
        child: FutureBuilder(
          future: _folderFuture,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Folder not found'));
            } else {
              final folderData = snapshot.data!;
              final String folderUsername = folderData['userName'] ?? 'Unknown';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Container(
                      child: Text(
                        folderUsername,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    // Thêm các thông tin khác của folder tại đây
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
