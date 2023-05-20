import 'package:flutter/material.dart';
import 'package:palliative_care/screens/authentication/large_auth_screen.dart';
import 'package:palliative_care/screens/authentication/login.dart';
import 'package:palliative_care/screens/authentication/signup.dart';
import '../../constants.dart';

class LoginAndSignupScreen extends StatefulWidget {
  static const String id = "LoginAndSignupPage";

  const LoginAndSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginAndSignupScreen> createState() => _LoginAndSignupScreenState();
}

class _LoginAndSignupScreenState extends State<LoginAndSignupScreen>
    with TickerProviderStateMixin {

  late PageController _pageController;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 700) {
      return const LargeAuthScreen();
    } else {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [kMainColorLight, kMainColorDark],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
              ),
              Column(
                children: [
                  kSizeBoxH16,
                  Image.asset("images/logo.png", height: 80, width: 80,),
                  const Text(
                    "Palliative Care",
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  kSizeBoxH8,
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: TabBar(
                                      labelColor: Colors.white,
                                      unselectedLabelColor: kMainColorLight,
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(120),
                                        color: kMainColorLight,
                                      ),
                                      controller: tabController,
                                      // isScrollable: true,
                                      labelPadding: const EdgeInsets.symmetric(horizontal: 32),
                                      tabs: const [
                                        Tab(
                                          child: Text("Login"),
                                        ),
                                        Tab(
                                          child: Text("Signup"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          kSizeBoxH32,
                          Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: const [
                                //
                                // Login
                                //
                                LoginPageView(),

                                //
                                // Sign Up
                                //

                                SignupPageView(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }
}
