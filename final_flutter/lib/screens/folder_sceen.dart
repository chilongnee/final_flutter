import 'package:flutter/material.dart';

class Folder extends StatefulWidget {
  const Folder({super.key});

  @override
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folder')),
      body: const Center(
        child: Text('Folder Screen', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
