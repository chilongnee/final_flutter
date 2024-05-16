import 'package:flutter/material.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DashBoard'),
        automaticallyImplyLeading: false, 
      ),
      
      body: Container(
        color: Colors.teal.shade200,
        child: const Center(
          child: Text('DashBoard Screen', style: TextStyle(fontSize: 40)),
        ),
      ),
    );
  }
}
