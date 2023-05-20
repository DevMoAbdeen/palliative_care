import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/screens/admin/home_screen_admin.dart';
import 'package:palliative_care/screens/doctor/page_view.dart';
import 'package:palliative_care/screens/patient/page_view.dart';
import '../authentication/login_and_signup_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = "SplashPage";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Duration duration = const Duration(seconds: 2);
  String returnUserRole = "";
  bool isUserLogin = false;


  Future<void> isLogin() async {
    String? currentUserEmail = FbAuthentication.getUserEmail();
    if (currentUserEmail != null) {
      isUserLogin = true;
      returnUserRole = (await FbAuthentication.getUserData(context, currentUserEmail) as UserModel).role;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    isLogin();
    controller = AnimationController(vsync: this, duration: duration);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });

    Timer(
      const Duration(milliseconds: 3000),
      () => isUserLogin
          ? returnUserRole == UserRole.Admin.name
              ? Navigator.pushReplacementNamed(context, HomeScreenAdmin.id)
              : returnUserRole == UserRole.Doctor.name
                  ? Navigator.pushReplacementNamed(context, PageViewDoctor.id)
                  : returnUserRole == UserRole.Patient.name
                      ? Navigator.pushReplacementNamed(context, PageViewPatient.id)
                      : Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id)
          : Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: controller.value * 200,
                    width: controller.value * 200,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Palliative Care',
                      textStyle: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isUserLogin
            ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Please wait..."),
                    SizedBox(width: 8,),
                    CircularProgressIndicator(strokeWidth: 2,)
                  ],
              ),
            )
            : const SizedBox(),
      ),
    );
  }
}
