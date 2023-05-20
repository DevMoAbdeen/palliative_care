import 'package:flutter/material.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/screens/doctor/doctor_articles_screen.dart';
import 'package:palliative_care/screens/doctor/large_doctor_screen.dart';
import 'package:palliative_care/screens/doctor/my_hidden_article_screen.dart';
import 'package:palliative_care/screens/joint/activity_screen.dart';
import 'package:palliative_care/screens/joint/all_users.dart';
import 'package:provider/provider.dart';
import '../../components/menu_lists.dart';
import '../../constants.dart';
import '../../functions.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';
import 'doctor_profile_screen.dart';
import 'home_screen_doctor.dart';
import 'doctor_topics_screen.dart';

class PageViewDoctor extends StatefulWidget {
  static const String id = "PageViewDoctor";

  const PageViewDoctor({Key? key}) : super(key: key);

  @override
  State<PageViewDoctor> createState() => _PageViewDoctorState();
}

class _PageViewDoctorState extends State<PageViewDoctor> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  PageController pageController = PageController();
  int pageIndex = 0;
  String selectedPageName = 'Home';

  bool isCheckFirebase = true;

  UserModel? currentUser;

  updateScreen() {
    setState(() {});
  }

  updatePageController(int index) {
    selectedPageName = index == 0 ? "Home" : index == 1 ? "Chat" : index == 2 ? "My Topics"
        : index == 3 ? "My Articles" : index == 4 ? "My Hidden Article" : index == 5 ? "My Profile" : "Your Activity";
    pageIndex = index;
    pageController.jumpToPage(pageIndex);
    updateScreen();
    scaffoldKey.currentState?.closeDrawer();
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
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 700) {
      return const LargeDoctorScreen();
    } else {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(selectedPageName),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: InkWell(
              onTap: () {
                scaffoldKey.currentState?.openDrawer();
              },
              child: currentUser!.imageUrl != null
                  ? CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(currentUser!.imageUrl!),
                    )
                  : const CircleAvatar(
                      radius: 24,
                      backgroundColor: kMainColorDark,
                      child: Center(child: Icon(Icons.person)),
                    ),
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: currentUser!.imageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(currentUser!.imageUrl!))
                    : const CircleAvatar(
                        backgroundColor: kMainColorDark,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 32,
                          ),
                        ),
                      ),
                accountName: Text(currentUser!.name),
                accountEmail: Text(currentUser!.email),
              ),
              ListTileDrawer(
                icon: Icons.home,
                text: "Home",
                // text: "الرئيسية",
                index: 0,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(0);
                },
              ),
              ListTileDrawer(
                icon: Icons.chat,
                text: "Chat",
                // text: "المحادثات",
                index: 1,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(1);
                },
              ),
              ListTileDrawer(
                icon: Icons.topic,
                text: "My Topics",
                // text: "مواضيعي",
                index: 2,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(2);
                },
              ),
              ListTileDrawer(
                icon: Icons.article,
                text: "My Articles",
                // text: "مقالاتي",
                index: 3,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(3);
                },
              ),
              ListTileDrawer(
                icon: Icons.visibility_off,
                text: "My Hidden Articles",
                // text: "مقالاتي المخفية",
                index: 4,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(4);
                },
              ),
              ListTileDrawer(
                icon: Icons.account_circle,
                text: "My Profile",
                // text: "الملف الشخصي",
                index: 5,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(5);
                },
              ),
              ListTileDrawer(
                icon: Icons.settings_backup_restore,
                text: "Your Activity",
                // text: "سجل النشاطات",
                index: 6,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(6);
                },
              ),
              ListTileDrawer(
                icon: Icons.logout,
                text: "Logout",
                // text: "تسجيل الخروج",
                index: 7,
                selectedIndex: pageIndex,
                fun: () async {
                  showDialog(context: context, builder: (BuildContext context) {
                    return AllFunctions.showDialogLogout(context);
                  });
                },
              ),
            ],
          ),
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          allowImplicitScrolling: false,
          controller: pageController,
          onPageChanged: (value) {
            pageIndex = value;
            updatePageController(pageIndex);
          },
          children: [
            const HomeScreenDoctor(),
            const AllUsersScreen(),
            DoctorTopicsScreen(doctorEmail: currentUser!.email),
            DoctorArticlesScreen(doctorEmail: currentUser!.email),
            MyHiddenArticleScreen(),
            DoctorProfileScreen(doctorEmail: currentUser!.email, isFromPageView: true),
            const YourActivityScreen(),
          ],
        ),
      );
    }
  }
}
