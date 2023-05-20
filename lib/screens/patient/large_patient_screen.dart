import 'package:flutter/material.dart';
import 'package:palliative_care/screens/joint/all_topics_screen.dart';
import 'package:palliative_care/screens/patient/all_articles_screen.dart';
import 'package:palliative_care/screens/patient/patient_profile_screen.dart';
import 'package:provider/provider.dart';
import '../../components/menu_lists.dart';
import '../../constants.dart';
import '../../firebase/fb_authentication.dart';
import '../../functions.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';
import '../joint/activity_screen.dart';
import '../joint/all_users.dart';

class LargePatientScreen extends StatefulWidget {
  const LargePatientScreen({Key? key}) : super(key: key);

  @override
  State<LargePatientScreen> createState() => _LargePatientScreenState();
}

class _LargePatientScreenState extends State<LargePatientScreen> {
  UserModel? currentUser;
  String selectedPageName = "Home";
  Widget selectedPage = const AllArticlesScreen();

  List<Map> allPages() {
    return [
      {
        "title": "Home",
        "page": const AllArticlesScreen(),
        "icon": Icons.home,
      },
      {
        "title": "All Topics",
        "page": const AllTopicsScreen(),
        "icon": Icons.category,
      },
      {
        "title": "Chat",
        "page": const AllUsersScreen(),
        "icon": Icons.chat,
      },
      {
        "title": "My Profile",
        "page": PatientProfileScreen(
            email: currentUser!.email, isFromPageView: false),
        "icon": Icons.account_circle,
      },
      {
        "title": "Your Activity",
        "page": const YourActivityScreen(),
        "icon": Icons.settings_backup_restore,
      },
      {
        "title": "Logout",
        "icon": Icons.logout,
      },
    ];
  }

  @override
  void initState() {
    currentUser =
        Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width / 3;

    return Row(
      children: [
        SizedBox(
          width: menuWidth,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text("Menu Items"),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  ListTile(
                    leading: currentUser!.imageUrl != null
                        ? CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                NetworkImage(currentUser!.imageUrl!),
                          )
                        : const CircleAvatar(
                            // radius: 40,
                            backgroundColor: kMainColorDark,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 32,
                              ),
                            ),
                          ),
                    title: Text(currentUser!.name),
                    subtitle: Text(currentUser!.email),
                  ),
                  kDivider,
                  Expanded(
                    child: ListView.builder(
                      itemCount: allPages().length,
                      itemBuilder: (context, index) {
                        return MenuListTile(
                          thisPageName: allPages()[index]["title"],
                          icon: allPages()[index]["icon"],
                          selectedPageName: selectedPageName,
                          onPressed: () {
                            if (allPages()[index]["title"] == "Logout") {
                              showDialog(context: context, builder: (BuildContext context) {
                                return AllFunctions.showDialogLogout(context);
                              });
                            } else {
                              setState(() {
                                selectedPageName = allPages()[index]["title"];
                                selectedPage = allPages()[index]["page"];
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const RotatedBox(
          quarterTurns: 1,
          child: Divider(height: 0.5, color: Colors.grey),
        ),
        Expanded(
          child: Scaffold(body: selectedPage),
        ),
      ],
    );
  }
}
