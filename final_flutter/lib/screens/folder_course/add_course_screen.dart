import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_flutter/widgets/multiselect_dialog.dart';
import 'package:final_flutter/widgets/add_vocab_container.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  late TextEditingController titleController;
  ValueNotifier<List<String>>? selectedTypes;

  String? selectedProgress;
  final List<Widget> _vocabContainers = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void _addVocabContainer() {
    setState(() {
      TextEditingController termController = TextEditingController();
      TextEditingController definitionController = TextEditingController();
      ValueNotifier<List<String>> selectedTypes =
          ValueNotifier<List<String>>([]);

      _vocabContainers.add(
        Column(
          children: [
            AddVocabContainer(
              termController: termController,
              definitionController: definitionController,
              selectedTypes: selectedTypes,
              showMultiSelect: () {
                _showMultiSelect(selectedTypes);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  void _showMultiSelect(ValueNotifier<List<String>> selectedTypes) async {
    final List<String> types = ['Noun', 'Adj', 'Verb', 'Adv'];

    final dynamic results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
            options: types, selectedOptions: selectedTypes.value);
      },
    );

    if (results != null && results is List<String>) {
      selectedTypes.value = results;
    }
  }

  Future<void> _saveCourseDataToFirestore(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentReference courseRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc();

      await courseRef.set({
        'title': titleController.text,
        'progress': selectedProgress,
      });

      for (var i = 0; i < _vocabContainers.length; i++) {
        var container = _vocabContainers[i];
        if (container is Column) {
          Widget child = container.children.first;
          if (child is AddVocabContainer) {
            AddVocabContainer vocabContainer = child;
            TextEditingController termController =
                vocabContainer.termController;
            TextEditingController definitionController =
                vocabContainer.definitionController;
            List<String> selectedTypes =
                vocabContainer.selectedTypes?.value ?? [];

            await courseRef.collection('vocabularies').add({
              'term': termController.text,
              'definition': definitionController.text,
              'types': selectedTypes,
            });
          }
        }
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 28, color: Colors.black),
            onPressed: () {
              _saveCourseDataToFirestore(context);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFBBEDF2),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            color: const Color(0xFFBBEDF2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tiêu đề',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                      TextField(
                        autofocus: true,
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tiến độ',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 180,
                        height: 35,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedProgress,
                            onChanged: (value) {
                              setState(() {
                                selectedProgress = value;
                              });
                            },
                            iconSize: 18,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 5.0),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                            ),
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                            items: <String>[
                              'Hoàn thành',
                              'Chưa hoàn thành',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: value == 'Hoàn thành'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: _vocabContainers,
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _addVocabContainer,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
