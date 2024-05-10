import 'package:flutter/material.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DashBoard'),
        automaticallyImplyLeading: false, ),
      body: const Center(
        child: Text('Community Screen', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
