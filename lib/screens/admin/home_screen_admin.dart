import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/functions.dart';
import 'package:palliative_care/screens/admin/add_doctor_screen.dart';
import 'package:palliative_care/screens/admin/show_all_users.dart';
import 'package:palliative_care/screens/joint/all_topics_screen.dart';
import '../patient/all_articles_screen.dart';

class HomeScreenAdmin extends StatefulWidget {
  static const String id = "HomeScreenAdmin";

  const HomeScreenAdmin({Key? key}) : super(key: key);

  @override
  State<HomeScreenAdmin> createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  int _selectedIndex = 0;
  String pageName = "All users";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageName = index == 0 ? "All users" : index == 1 ? "Add doctor" : index == 2 ? "All Topics" : "All Articles";
    });
  }

  static const List<Widget> _pages = <Widget>[
    ShowAllUsers(),
    AddDoctorScreen(),
    AllTopicsScreen(),
    AllArticlesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AllFunctions.showDialogLogout(context);
                    },
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: kMainColorDark,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Show Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: "Add Doctor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Show Topics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Show Articles",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.logout),
          //   label: "Logout",
          // ),
        ],
      ),
    );
  }
}
