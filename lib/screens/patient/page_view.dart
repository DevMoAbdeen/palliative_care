import 'package:flutter/material.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/screens/joint/activity_screen.dart';
import 'package:palliative_care/screens/joint/all_topics_screen.dart';
import 'package:palliative_care/screens/joint/all_users.dart';
import 'package:palliative_care/screens/patient/all_articles_screen.dart';
import 'package:palliative_care/screens/patient/large_patient_screen.dart';
import 'package:palliative_care/screens/patient/patient_profile_screen.dart';
import 'package:provider/provider.dart';
import '../../components/menu_lists.dart';
import '../../constants.dart';
import '../../functions.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class PageViewPatient extends StatefulWidget {
  static const String id = "PageViewPatient";

  const PageViewPatient({Key? key}) : super(key: key);

  @override
  State<PageViewPatient> createState() => _PageViewPatientState();
}

class _PageViewPatientState extends State<PageViewPatient> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController = PageController();
  int pageIndex = 0;
  String selectedPageName = 'Home';
  UserModel? currentUser;

  updateScreen() {
    setState(() {});
  }

  updatePageController(int index) {
    selectedPageName = index == 0 ? "Home" : index == 1 ? "All Topics"
        // : index == 2 ? "Subscriber It"
        : index == 2 ? "Chat"
        : index == 3 ? "My Profile" : "Your Activity";
    pageIndex = index;
    pageController.jumpToPage(pageIndex);
    scaffoldKey.currentState?.closeDrawer();
    updateScreen();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if(currentUser == null){
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 700) {
      return const LargePatientScreen();
    }else{
      return Scaffold(
        backgroundColor: kBackgroundColor,
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(selectedPageName),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: currentUser!.imageUrl != null ? CircleAvatar(
                    backgroundImage: NetworkImage(currentUser!.imageUrl!)
                ) : const CircleAvatar(backgroundColor: kMainColorDark, child: Center(child: Icon(Icons.person, size: 32,))),
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
                icon: Icons.category,
                text: "All Topics",
                // text: "جميع المواضيع",
                index: 1,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(1);
                },
              ),
              // ListTileDrawer(
              //   icon: Icons.subscriptions_outlined,
              //   text: "Subscriber It",
              //   index: 2,
              //   selectedIndex: pageIndex,
              //   fun: () {
              //     updatePageController(2);
              //   },
              // ),
              ListTileDrawer(
                icon: Icons.chat,
                text: "Chat",
                // text: "المحادثات",
                index: 2,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(2);
                },
              ),
              ListTileDrawer(
                icon: Icons.account_circle,
                text: "My Profile",
                // text: "الملف الشخصي",
                index: 3,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(3);
                },
              ),
              ListTileDrawer(
                icon: Icons.settings_backup_restore,
                text: "Your Activity",
                // text: "سجل النشاطات",
                index: 4,
                selectedIndex: pageIndex,
                fun: () {
                  updatePageController(4);
                },
              ),
              ListTileDrawer(
                icon: Icons.logout,
                text: "Logout",
                // text: "تسجيل الخروج",
                index: 5,
                selectedIndex: pageIndex,
                fun: () async {
                  showDialog(context: context,
                      builder: (BuildContext context){
                        return AllFunctions.showDialogLogout(context);
                      }
                  );
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
            updatePageController(value);
          },
          children: [
            const AllArticlesScreen(),
            const AllTopicsScreen(),
            const AllUsersScreen(),
            PatientProfileScreen(email: currentUser!.email, isFromPageView: true),
            const YourActivityScreen(),
          ],
        ),
      );
    }
  }
}