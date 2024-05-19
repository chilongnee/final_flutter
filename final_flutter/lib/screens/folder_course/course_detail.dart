import 'package:final_flutter/screens/folder_course/edit_course_detail_screen.dart';
import 'package:final_flutter/screens/folder_course/memory_card.dart';
import 'package:final_flutter/screens/folder_course/ranking_screen.dart';
import 'package:final_flutter/screens/folder_course/summarize_memory_card.dart';
import 'package:final_flutter/screens/folder_course/quiz_test.dart';
import 'package:final_flutter/screens/folder_course/type_test.dart';
import 'package:final_flutter/widgets/bottom_sheet.dart';
import 'package:final_flutter/widgets/multiselect_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CourseDetail extends StatefulWidget {
  final String userId;
  final String courseId;

  const CourseDetail({
    super.key,
    required this.userId,
    required this.courseId,
  });

  @override
  _CourseDetailState createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  late Future<DocumentSnapshot> _courseFuture;
  late FlutterTts flutterTts = FlutterTts();
  late Map<String, bool> _isClickedMap;

  @override
  void initState() {
    super.initState();
    _courseFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: _courseFuture,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 28, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => BottomSheetWidget(
                  height: 200,
                  buttons: const [
                    Text('Sửa học phần'),
                    Text('Thêm vào thư mục'),
                  ],
                  onPressed: (index) {
                    switch (index) {
                      case 0:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCourseDetailScreen(
                                courseId: widget.courseId),
                          ),
                        );
                        break;
                      case 1:
                        print('Nhấn Thêm vào thư mục');
                        break;
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: Colors.teal.shade200,
        child: FutureBuilder(
          future: _courseFuture,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Course not found'));
            } else {
              final courseData = snapshot.data!;
              final String courseTitle = courseData['title'];
              final String progress = courseData['progress'];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.grey[200],
                              // image: DecorationImage(
                              //   image: NetworkImage('URL_HINH_ANH'),
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                            child: const Icon(Icons.image),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              courseTitle,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildBox(context, 'Thẻ ghi nhớ'),
                    _buildBox(context, 'Học (Type)'),
                    _buildBox(context, 'Kiểm tra (Quiz)'),
                    _buildBox(context, 'Xếp hạng'),
                    const SizedBox(height: 16.0),
                    _buildBoxForVocabularies(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        _handleBoxTap(context, title);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }

  void _handleBoxTap(BuildContext context, String title) async{
    // Thực hiện điều gì đó dựa vào title
    // Ví dụ: chuyển sang màn hình tương ứng với title
    switch (title) {
      case 'Thẻ ghi nhớ':
        navigateToSummarize(context);
        break;
      case 'Học (Type)':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TypeTest(userId: widget.userId, courseId: widget.courseId)),
        );
        break;
      case 'Kiểm tra (Quiz)':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  QuizTest(userId: widget.userId, courseId: widget.courseId)),
        );
        break;
      case 'Xếp hạng':
         bool hasRankingData = await _checkRankingData();
        if (hasRankingData) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RankingScreen(
                    userId: widget.userId, courseId: widget.courseId)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Không có dữ liệu xếp hạng'),
            ),
          );
        }
        break;
      default:
        // Xử lý mặc định nếu không có trường hợp nào khớp
        break;
    }
  }

  Widget _buildBoxForVocabularies() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _fetchVocabularies(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No vocabularies found');
          } else {
            final List<DocumentSnapshot> vocabularies = snapshot.data!.docs;
            final List<DocumentSnapshot> studyingVocabularies = vocabularies
                .where((vocabulary) => vocabulary['status'] == 'Đang học')
                .toList();
            final List<DocumentSnapshot> learnedVocabularies = vocabularies
                .where((vocabulary) => vocabulary['status'] == 'Đã biết')
                .toList();

            _isClickedMap = {
              for (var vocab in vocabularies) vocab.id: vocab['star'] ?? false
            };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thuật ngữ trong học phần này (${vocabularies.length})',
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                studyingVocabularies.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đang học (${studyingVocabularies.length})',
                            style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(255, 152, 58, 1)),
                          ),
                          const Text(
                            'Bạn đã bắt đầu học những thuật ngữ này. Tiếp tục phát huy nhé!',
                            style: TextStyle(
                                fontSize: 13.0, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 8.0),
                          Column(
                            children: studyingVocabularies
                                .map((DocumentSnapshot vocabulary) {
                              final List<dynamic> types = vocabulary['types'];
                              final String vocabularyName = vocabulary['term'];
                              final String vocabularyMeaning =
                                  vocabulary['definition'];
                              final String vocabId = vocabulary.id;
                              final bool isStar = vocabulary['star'] ?? false;
                              return _buildBoxForVocabulary(vocabularyName,
                                  vocabularyMeaning, types, vocabId, isStar);
                            }).toList(),
                          ),
                        ],
                      )
                    : const SizedBox(),
                learnedVocabularies.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thành thạo (${learnedVocabularies.length})',
                            style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          const Text(
                            'Bạn đã trả lời đúng các thuật ngữ này!',
                            style: TextStyle(
                                fontSize: 13.0, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 8.0),
                          Column(
                            children: learnedVocabularies
                                .map((DocumentSnapshot vocabulary) {
                              final List<dynamic> types = vocabulary['types'];
                              final String vocabularyName = vocabulary['term'];
                              final String vocabularyMeaning =
                                  vocabulary['definition'];
                              final String vocabId = vocabulary.id;
                              final bool isStar = vocabulary['star'] ?? false;
                              return _buildBoxForVocabulary(vocabularyName,
                                  vocabularyMeaning, types, vocabId, isStar);
                            }).toList(),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildBoxForVocabulary(String vocabularyName, String vocabularyMeaning,
      List<dynamic> types, String vocabId, bool isStar) {
    var screenSize = MediaQuery.of(context).size;
    return Slidable(
        key: ValueKey(vocabId),
        endActionPane: ActionPane(motion: const BehindMotion(), children: [
          SlidableAction(
            onPressed: (BuildContext context) => _deleteVocabulary(vocabId),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            icon: Icons.delete,
            padding: const EdgeInsets.all(16.0),
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (BuildContext context) => _onEditVocabulary(
                vocabId, vocabularyName, vocabularyMeaning, types, isStar),
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            icon: Icons.edit,
            label: 'Edit',
          ),
        ]),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocabularyName,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      vocabularyMeaning,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: types
                          .map((type) => Chip(
                                label: Text(
                                  type.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.blue,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isClickedMap[vocabId] = !_isClickedMap[vocabId]!;
                    _saveVocabStar(_isClickedMap[vocabId]!, vocabId);
                  });
                },
                icon: isStar
                    ? const Icon(Icons.star_outlined)
                    : const Icon(Icons.star_border_outlined),
                iconSize: screenSize.width * 0.05,
                color: isStar ? Colors.amber : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  _speak(vocabularyName);
                },
              ),
            ],
          ),
        ));
  }

  void _onEditVocabulary(
      String vocabId,
      String currentVocabularyName,
      String currentVocabularyMeaning,
      List<dynamic> currentTypes,
      bool isStar) {
    String editedVocabularyName = currentVocabularyName;
    String editedVocabularyMeaning = currentVocabularyMeaning;
    List<dynamic> editedTypes = List.from(currentTypes);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chỉnh sửa từ vựng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Tên từ vựng'),
                    onChanged: (newValue) {
                      editedVocabularyName = newValue;
                    },
                    controller:
                        TextEditingController(text: editedVocabularyName),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Ý nghĩa'),
                    onChanged: (newValue) {
                      editedVocabularyMeaning = newValue;
                    },
                    controller:
                        TextEditingController(text: editedVocabularyMeaning),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Loại từ',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () =>
                                _addTypeDialog(context, editedTypes, setState),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              minimumSize: const Size(20, 20),
                              backgroundColor: Colors.teal.shade200,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Text(
                                'Chọn',
                                style:
                                    TextStyle(fontSize: 8, color: Colors.black),
                              ),
                            ),
                          )
                        ],
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: editedTypes.map((type) {
                          return Chip(
                            label: Text(type.toString()),
                            onDeleted: () {
                              setState(() {
                                editedTypes.remove(type);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _updateVocabulary(vocabId, editedVocabularyName,
                        editedVocabularyMeaning, editedTypes, isStar);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Lưu'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
              ],
            );
          },
        );
      },
    );
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

  void _addTypeDialog(
      BuildContext context, List<dynamic> editedTypes, Function setState) {
    final selectedTypes = ValueNotifier<List<String>>(
        List.from(editedTypes.map((type) => type.toString())));

    _showMultiSelect(selectedTypes);

    selectedTypes.addListener(() {
      setState(() {
        editedTypes.clear();
        editedTypes.addAll(selectedTypes.value);
      });
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  Stream<QuerySnapshot> _fetchVocabularies() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .snapshots();
  }

  Future<void> _saveVocabStar(bool isStar, String vocabId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .doc(vocabId)
        .update({'star': isStar});
  }

  Future<void> navigateToSummarize(BuildContext context) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('vocabularies')
        .get();

    int learnedCount = 0;
    int studyingCount = 0;
    for (var doc in querySnapshot.docs) {
      if ((doc.data() as Map<String, dynamic>)['status'] == 'Đã biết') {
        learnedCount++;
      } else if ((doc.data() as Map<String, dynamic>)['status'] == 'Đang học') {
        studyingCount++;
      }
    }

    if (learnedCount == querySnapshot.docs.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SummarizeMemoryCard(
                studyingCount: studyingCount,
                learnedCount: learnedCount,
                courseId: widget.courseId,
                userId: widget.userId)),
      );
    } else if (learnedCount < querySnapshot.docs.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MemoryCardScreen(
                userId: widget.userId, courseId: widget.courseId)),
      );
    }
  }

  Future<void> _deleteVocabulary(String vocabId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('courses')
          .doc(widget.courseId)
          .collection('vocabularies')
          .doc(vocabId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Xóa từ vựng thành công'),
      ));
    } catch (e) {
      print('Lỗi khi xóa từ vựng: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Đã xảy ra lỗi khi xóa từ vựng'),
      ));
    }
  }

  Future<void> _updateVocabulary(
      String vocabId,
      String editedVocabularyName,
      String editedVocabularyMeaning,
      List<dynamic> editedTypes,
      bool isStar) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('courses')
          .doc(widget.courseId)
          .collection('vocabularies')
          .doc(vocabId)
          .update({
        'term': editedVocabularyName,
        'definition': editedVocabularyMeaning,
        'types': editedTypes,
        'star': isStar,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Cập nhật từ vựng thành công'),
      ));
    } catch (e) {
      print('Lỗi khi cập nhật từ vựng: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Đã xảy ra lỗi khi cập nhật từ vựng'),
      ));
    }
  }
   Future<bool> _checkRankingData() async {
    final rankingCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('courses')
        .doc(widget.courseId)
        .collection('ranking');

    final docSnapshot = await rankingCollection.doc(widget.userId).get();

    return docSnapshot.exists;
  }
}