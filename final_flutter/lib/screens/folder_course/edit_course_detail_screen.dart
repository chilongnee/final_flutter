import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_flutter/widgets/multiselect_dialog.dart';
import 'package:final_flutter/widgets/add_vocab_container.dart';

class EditCourseDetailScreen extends StatefulWidget {
  final String courseId;

  const EditCourseDetailScreen({super.key, required this.courseId});

  @override
  _EditCourseDetailScreenState createState() => _EditCourseDetailScreenState();
}

class _EditCourseDetailScreenState extends State<EditCourseDetailScreen> {
  late TextEditingController titleController;
  ValueNotifier<List<String>>? selectedTypes;
  String? username;
  String? selectedProgress;
  String? selectedStatus;
  final List<Widget> _vocabContainers = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    getUsernameFromFirestore();
    loadCourseData();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> loadCourseData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('courses')
            .doc(widget.courseId)
            .get();

        if (courseSnapshot.exists) {
          setState(() {
            titleController.text = courseSnapshot['title'];
            selectedProgress = courseSnapshot['progress'];
            selectedStatus = courseSnapshot['status'];
          });

          QuerySnapshot vocabSnapshot =
              await courseSnapshot.reference.collection('vocabularies').get();

          setState(() {
            _vocabContainers.clear();
            for (var doc in vocabSnapshot.docs) {
              TextEditingController termController =
                  TextEditingController(text: doc['term']);
              TextEditingController definitionController =
                  TextEditingController(text: doc['definition']);
              ValueNotifier<List<String>> selectedTypes =
                  ValueNotifier<List<String>>(List<String>.from(doc['types']));

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
            }
          });
        } else {
          print("Course document does not exist");
        }
      } else {
        print("User is not logged in");
      }
    } catch (e) {
      print("Error loading course data: $e");
    }
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

  void getUsernameFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userSnapshot.exists) {
          setState(() {
            username = userSnapshot['userName'];
          });
        } else {
          setState(() {
            username = 'Unknown';
          });
        }
      }
    } catch (e) {
      print("Error getting username: $e");
    }
  }

  Future<void> _saveCourseDataToFirestore(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (_vocabContainers.length < 3) {
          _showAlert(context, 'Phải tạo tối thiểu 3 vocab');
          return;
        }

        bool allFieldsFilled = true;
        for (var container in _vocabContainers) {
          if (container is Column) {
            Widget child = container.children.first;
            if (child is AddVocabContainer) {
              if (child.termController.text.isEmpty ||
                  child.definitionController.text.isEmpty) {
                allFieldsFilled = false;
                break;
              }
            }
          }
        }

        if (!allFieldsFilled) {
          _showAlert(context, 'Tất cả các trường phải được điền');
          return;
        }

        String userId = user.uid;

        DocumentReference courseRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(widget.courseId);

        await courseRef.update({
          'title': titleController.text,
          'progress': selectedProgress,
          'status': selectedStatus,
          'username': username,
          'userId': userId,
        });

        QuerySnapshot existingVocabSnapshot =
            await courseRef.collection('vocabularies').get();
        for (var doc in existingVocabSnapshot.docs) {
          await doc.reference.delete();
        }

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

              DocumentReference vocabRef =
                  await courseRef.collection('vocabularies').add({
                'star': false,
                'status': 'Đang học',
                'term': termController.text,
                'definition': definitionController.text,
                'types': selectedTypes,
              });
              String vocabId = vocabRef.id;
              await vocabRef.update({'id': vocabId});
            }
          }
        }

        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving course data: $e");
    }
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        contentPadding: const EdgeInsets.all(10),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _importFromCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        if (fields.isNotEmpty) {
          print('CSV:');
          for (var row in fields) {
            print(row);
          }

          setState(() {
            titleController.text = fields[0][0];

            _vocabContainers.clear();

            int termColumnIndex = 0;
            int definitionColumnIndex = 1;
            int typesStartIndex = 2;

            for (int i = 1; i < fields.length; i++) {
              TextEditingController termController =
                  TextEditingController(text: fields[i][termColumnIndex]);
              TextEditingController definitionController =
                  TextEditingController(text: fields[i][definitionColumnIndex]);
              ValueNotifier<List<String>> selectedTypes =
                  ValueNotifier<List<String>>(
                      fields[i].sublist(typesStartIndex).cast<String>());

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
            }
          });
        }
      } else {
        _showAlert(context, 'Không thể chọn file.');
      }
    } catch (e) {
      print("Error importing from CSV: $e");
      _showAlert(context, 'Đã xảy ra lỗi khi nhập file CSV.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa Học Phần'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 28, color: Colors.black),
            onPressed: () {
              _saveCourseDataToFirestore(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.teal.shade200,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            color: Colors.teal.shade200,
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
                  GestureDetector(
                    onTap: _importFromCsv,
                    child: const Row(
                      children: [
                        Icon(Icons.file_upload_outlined,
                            size: 23, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'Thêm bằng file CSV',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
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
                  Row(
                    children: [
                      const Text(
                        'Ai có thể xem',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
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
                            value: selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value;
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
                              'Mọi người',
                              'Chỉ mình tôi',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: value == 'Mọi người'
                                        ? Colors.green
                                        : Colors.black,
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
