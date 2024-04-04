import 'package:final_flutter/login/firebase_auth_service.dart';
import 'package:flutter/material.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/community_screen.dart';
import 'screens/folder_sceen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_folder_screen.dart';
// Widget
import 'widgets/bottom_nav_button.dart';
import 'widgets/bottom_sheet.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;
  late final List<Widget> screens;
  FirebaseAuthService _auth = new FirebaseAuthService();
  @override
  void initState() {
    super.initState();
    print(_auth.currentUser?.email);
    screens = [
      const DashBoard(),
      const Community(),
      const Folder(),
      const Profile(),
    ];
  }

  Widget buildBottomNavigationButton(
      int tabIndex, String iconPath, String label) {
    return BottomNavigationButton(
      // Sử dụng bottom_nav_button.dart
      tabIndex: tabIndex,
      iconPath: iconPath,
      label: label,
      isSelected: currentTab == tabIndex,
      onPressed: (int index) {
        setState(() {
          currentScreen = screens[index];
          currentTab = index;
        });
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const BottomSheetWidget(
          height: 200,
          buttons: [Text('Học Phần'), Text('Thư mục')],
        );
      },
    );
  }

  late Widget currentScreen;
  @override
  Widget build(BuildContext context) {
    currentScreen = screens[currentTab];

    return Scaffold(
      body: currentScreen,
      backgroundColor: const Color(0xFFBBEDF2),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        onPressed: () {
          _showBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBottomNavigationButton(0, 'home', 'Home'),
                  buildBottomNavigationButton(1, 'people', 'Community'),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBottomNavigationButton(2, 'folder', 'Folder'),
                  buildBottomNavigationButton(3, 'profile', 'Profile'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
