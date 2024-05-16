import 'package:flutter/material.dart';

class AddVocabContainer extends StatefulWidget {
  final TextEditingController termController;
  final TextEditingController definitionController;
  final ValueNotifier<List<String>>? selectedTypes;
  final void Function() showMultiSelect;

  const AddVocabContainer({
    super.key,
    required this.termController,
    required this.definitionController,
    this.selectedTypes,
    required this.showMultiSelect,
  });

  @override
  _AddVocabContainerState createState() => _AddVocabContainerState();
}

class _AddVocabContainerState extends State<AddVocabContainer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable:
          widget.selectedTypes ?? ValueNotifier<List<String>>([]),
      builder: (context, selectedTypes, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thuật ngữ',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black,
                ),
              ),
              TextField(
                controller: widget.termController,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(fontSize: 12),
                ),
                style: const TextStyle(fontSize: 12),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
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
                          onPressed: widget.showMultiSelect,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedTypes.map((type) {
                                Color? borderColor;
                                Color? textColor;
                                switch (type) {
                                  case 'Noun':
                                    borderColor = Colors.red;
                                    textColor = Colors.red;
                                    break;
                                  case 'Adj':
                                    borderColor = Colors.blue;
                                    textColor = Colors.blue;
                                    break;
                                  case 'Verb':
                                    borderColor = Colors.green;
                                    textColor = Colors.green;
                                    break;
                                  case 'Adv':
                                    borderColor = Colors.orange;
                                    textColor = Colors.orange;
                                    break;
                                  default:
                                    borderColor = Colors.grey;
                                    textColor = Colors.black;
                                    break;
                                }
                                return Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: borderColor, width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                        fontSize: 10.0, color: textColor),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Định nghĩa',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                      ),
                    ),
                    TextField(
                      controller: widget.definitionController,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(fontSize: 12),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
