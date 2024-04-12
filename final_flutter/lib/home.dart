import 'package:flutter/material.dart';

// SCREEN
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/folder/folder_sceen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/folder/add_folder_screen.dart';
// WIDGET
import 'widgets/bottom_nav_button.dart';
import 'widgets/bottom_sheet.dart';
// FIREBASE
import 'package:final_flutter/screens/login/firebase_auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;
  late final List<Widget> screens;
  final FirebaseAuthService _auth = FirebaseAuthService();
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
        return BottomSheetWidget(
          height: 200,
          buttons: const [
            Text('Học Phần'),
            Text('Thư mục'),
          ],
          onPressed: (int index) {
            if (index == 1) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const AddFolderScreen()), // Chuyển hướng sang trang AddFolderScreen
              );
            }
          },
        );
      },
    );
  }

  void _handleTabSelection(int index) {
    setState(() {
      currentScreen = screens[index];
      currentTab = index;
    });
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
