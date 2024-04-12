import 'package:flutter/material.dart';

class BottomSheetWidget extends StatelessWidget {
  final double height;
  final List<Widget> buttons;
  final Function(int) onPressed; // Thêm thuộc tính onPressed

  const BottomSheetWidget({
    super.key,
    required this.height,
    required this.buttons,
    required this.onPressed, // Cập nhật constructor
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 120,
            height: 4,
            margin: const EdgeInsets.only(top: 5, bottom: 20),
            color: Colors.black,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons.asMap().entries.map((entry) {
              final int index = entry.key;
              final Widget button = entry.value;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFBBEDF2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MaterialButton(
                  onPressed: () {
                    onPressed(index); // Gọi onPressed khi button được nhấn
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minWidth: screenWidth - 40,
                  height: 40,
                  child: Text(
                    button is Text ? button.data as String : '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
