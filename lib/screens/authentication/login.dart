import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/screens/admin/home_screen_admin.dart';
import 'package:palliative_care/shared_preference.dart';
import '../../components/main_widgets.dart';
import '../../constants.dart';
import '../../models/user.dart';
import '../doctor/page_view.dart';
import '../patient/page_view.dart';

class LoginPageView extends StatefulWidget {
  static const String id = "LoginPageView";

  const LoginPageView({Key? key}) : super(key: key);

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isVisibleLogin = false;
  bool showProgress = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: kTextFieldDecoration.copyWith(
              hintText: 'Email',
              prefixIcon: const Icon(Icons.email)),
        ),
        kSizeBoxH8,
        TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: !isVisibleLogin,
          decoration: kTextFieldDecoration.copyWith(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isVisibleLogin = !isVisibleLogin;
                });
              },
              icon: isVisibleLogin
                  ? const Icon(Icons.visibility, color: Colors.grey,)
                  : const Icon(Icons.visibility_off, color: Colors.grey,),
            ),
          ),
        ),
        kSizeBoxH32,
        kSizeBoxH16,
        MainBtn(
          // text: "تسجيل الدخول",
          text: "Login",
          showProgress: showProgress,
          onPressed: () async {
            String email = emailController.text.trim().toString();
            String password = passwordController.text.trim().toString();

            if (email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fill all fields !')),
                // const SnackBar(content: Text('إملأ جميع الخانات')),
              );
            } else {
              if (password.length >= 6) {
                setState(() {
                  showProgress = true;
                });
                try {
                  final currentUser = await FbAuthentication.loginWithEmailAndPassword(email, password);
                  if (currentUser.user != null && mounted) {
                    UserModel? userModel = await FbAuthentication.getUserData(context, currentUser.user!.email!);
                    if(userModel == null && mounted){
                      var snackBar = const SnackBar(content: Text('This account may have been deleted, Please try later'));
                      // var snackBar = const SnackBar(content: Text('ربما تم حذف هذا الحساب ، يرجى المحاولة لاحقا'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }else{
                      String? myTokenNow = SharedPreferenceHelper.getMyToken();
                      if(myTokenNow != null && userModel!.token != myTokenNow){
                        await FbAuthentication.updateUserToken(context, email, myTokenNow!);
                        userModel.subscribedTopics.forEach((element) async {
                          await FirebaseMessaging.instance.subscribeToTopic(element);
                        });
                      }
                      if (userModel!.role == UserRole.Admin.name && mounted) {
                        Navigator.pushReplacementNamed(context, HomeScreenAdmin.id);
                      } else if (userModel.role == UserRole.Doctor.name && mounted) {
                        Navigator.pushReplacementNamed(context, PageViewDoctor.id);
                      } else if (userModel.role == UserRole.Patient.name && mounted) {
                        Navigator.pushReplacementNamed(context, PageViewPatient.id);
                      } else {
                        var snackBar = const SnackBar(content: Text('You cannot login to your account, Please retry again'));
                        // var snackBar = const SnackBar(content: Text('لا يمكنك تسجيل الدخول لحسابك, حاول مرة أخرى'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                    var snackBar = const SnackBar(content: Text('The password is wrong, or No user found for that email'));
                    // var snackBar = const SnackBar(content: Text('كلمة المرور غير صحيحة أو لا يوجد حساب بهذا الإيميل'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }else if(e.code == "invalid-email"){
                    var snackBar = const SnackBar(content: Text('This email is not valid!'));
                    // var snackBar = const SnackBar(content: Text('هذا الإيميل غير صالح'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                } catch(e){
                  var snackBar = SnackBar(content: Text('Error, $e'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              } else {
                var snackBar = const SnackBar(content: Text('The password must be at least 6 characters.'));
                // var snackBar = const SnackBar(content: Text('كلمة المرور ضعيفة, يجب أن لا تقل عن 5 حروف'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
            setState(() {
              showProgress = false;
            });
          },
        ),
      ],
    );
  }
}
