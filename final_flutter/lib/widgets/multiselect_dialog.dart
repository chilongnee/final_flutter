import 'package:flutter/material.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;

  const MultiSelectDialog({
    required this.options,
    this.selectedOptions = const [],
    super.key,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.selectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Chọn loại từ',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: widget.options.map((String type) {
            return CheckboxListTile(
              title: Text(type),
              value: _selectedOptions.contains(type),
              onChanged: (bool? value) {
                setState(() {
                  if (value != null && value) {
                    _selectedOptions.add(type);
                  } else {
                    _selectedOptions.remove(type);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity
                  .leading, // Di chuyển ô chọn sang bên trái
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedOptions);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
