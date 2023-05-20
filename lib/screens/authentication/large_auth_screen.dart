import 'package:flutter/material.dart';
import 'package:palliative_care/screens/authentication/login.dart';
import 'package:palliative_care/screens/authentication/signup.dart';
import '../../constants.dart';

class LargeAuthScreen extends StatefulWidget {
  const LargeAuthScreen({Key? key}) : super(key: key);

  @override
  State<LargeAuthScreen> createState() => _LargeAuthScreenState();
}

class _LargeAuthScreenState extends State<LargeAuthScreen> {

  String selectedPageName = "تسجيل دخول";

  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width / 2.5;

    return Row(
      children: [
        SizedBox(
          width: menuWidth,
          child: Scaffold(
            backgroundColor: kBackgroundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 1.5,
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
                      Image.asset("images/logo.png", height: 80, width: 80,),
                      const Text(
                        "Palliative Care",
                        style: TextStyle(color: Colors.white, fontSize: 28),
                      ),
                      kSizeBoxH8,
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white),
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                          ),
                          child: ListView(
                            children: [
                              CardPageView(
                                pageName: "تسجيل دخول",
                                isSelected: selectedPageName == "تسجيل دخول",
                                onPressed: () {
                                  setState(() {
                                    selectedPageName = "تسجيل دخول";
                                  });
                                },
                              ),
                              CardPageView(
                                pageName: "إنشاء حساب",
                                isSelected: selectedPageName == "إنشاء حساب",
                                onPressed: () {
                                  setState(() {
                                    selectedPageName = "إنشاء حساب";
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
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
          child: Scaffold(
            appBar: AppBar(
              title: Text(selectedPageName),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: selectedPageName == "تسجيل دخول"
                    ? const LoginPageView()
                    : const SignupPageView(),
              ),
          ),
        ),
      ],
    );
  }
}

class CardPageView extends StatelessWidget {
  final String pageName;
  final bool isSelected;
  final Function onPressed;

  const CardPageView({Key? key, required this.pageName, required this.isSelected, required this.onPressed}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? kMainColorDark : Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                pageName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
