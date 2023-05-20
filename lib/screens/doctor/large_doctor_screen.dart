import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/screens/doctor/doctor_articles_screen.dart';
import 'package:palliative_care/screens/doctor/doctor_profile_screen.dart';
import 'package:palliative_care/screens/doctor/doctor_topics_screen.dart';
import 'package:palliative_care/screens/doctor/home_screen_doctor.dart';
import 'package:palliative_care/screens/joint/activity_screen.dart';
import 'package:palliative_care/screens/joint/all_users.dart';
import 'package:provider/provider.dart';
import '../../components/menu_lists.dart';
import '../../firebase/fb_authentication.dart';
import '../../functions.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';
import 'my_hidden_article_screen.dart';

class LargeDoctorScreen extends StatefulWidget {
  const LargeDoctorScreen({Key? key}) : super(key: key);

  @override
  State<LargeDoctorScreen> createState() => _LargeDoctorScreenState();
}

class _LargeDoctorScreenState extends State<LargeDoctorScreen> {
  UserModel? currentUser;
  String selectedPageName = "Home";
  Widget selectedPage = const HomeScreenDoctor();

  List<Map> allPages() {
    return [
      {
        "title": "Home",
        "page": const HomeScreenDoctor(),
        "icon": Icons.home,
      },
      {
        "title": "Chat",
        "page": const AllUsersScreen(),
        "icon": Icons.chat,
      },
      {
        "title": "My Topics",
        "page": DoctorTopicsScreen(doctorEmail: currentUser!.email),
        "icon": Icons.topic,
      },
      {
        "title": "My Articles",
        "page": DoctorArticlesScreen(doctorEmail: currentUser!.email),
        "icon": Icons.article,
      },
      {
        "title": "My Hidden Articles",
        "page": MyHiddenArticleScreen(),
        "icon": Icons.visibility_off,
      },
      {
        "title": "My Profile",
        "page": DoctorProfileScreen(doctorEmail: currentUser!.email, isFromPageView: false),
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
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
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
                            setState(() {
                              if (allPages()[index]["title"] == "Logout") {
                                showDialog(context: context, builder: (BuildContext context) {
                                  return AllFunctions.showDialogLogout(context);
                                });
                              } else {
                                selectedPageName = allPages()[index]["title"];
                                selectedPage = allPages()[index]["page"];
                              }
                            });
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
