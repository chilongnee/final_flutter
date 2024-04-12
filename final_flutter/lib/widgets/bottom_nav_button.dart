import 'package:flutter/material.dart';

class BottomNavigationButton extends StatelessWidget {
  final int tabIndex;
  final String iconPath;
  final String label;
  final bool isSelected;
  final Function(int) onPressed;

  const BottomNavigationButton({
    super.key,
    required this.tabIndex,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialButton(
      minWidth: screenWidth / 6,
      onPressed: () => onPressed(tabIndex),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: SizedBox(
              width: 25,
              height: 25,
              child: Image.asset(isSelected
                  ? 'lib/icons/${iconPath}_black.png'
                  : 'lib/icons/${iconPath}_white.png'),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
