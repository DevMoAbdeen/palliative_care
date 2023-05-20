import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/shared_preference.dart';
import '../../components/main_widgets.dart';
import '../../constants.dart';
import '../../firebase/fb_activity.dart';
import '../patient/page_view.dart';

class SignupPageView extends StatefulWidget {
  static const String id = "SignupPageView";

  const SignupPageView({Key? key}) : super(key: key);

  @override
  State<SignupPageView> createState() => _SignupPageViewState();
}

class _SignupPageViewState extends State<SignupPageView> {

  TextEditingController nameController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isVisibleSignup = false;
  bool isUserDoctor = false;
  bool showProgress = false;


  @override
  void dispose() {
    nameController.dispose();
    birthdateController.dispose();
    addressController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextFormField(
          controller: nameController,
          keyboardType: TextInputType.name,
          decoration: kTextFieldDecoration.copyWith(
              hintText: 'Write full name',
              // hintText: 'أكتب اسمك كامل',
            prefixIcon: const Icon(Icons.account_circle)
          ),
          // textAlign: TextAlign.right,
        ),
        kSizeBoxH8,
        TextField(
          controller: birthdateController,
          readOnly: true,
          decoration: kTextFieldDecoration.copyWith(
              hintText: "Select your birthdate",
              // hintText: "حدد تاريخ ميلادك",
              prefixIcon: const Icon(Icons.calendar_today),
          ),
          // textAlign: TextAlign.right,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1930),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              setState(() {
                birthdateController.text = formattedDate; //set output date to TextField value.
              });
            }
          },
        ),
        kSizeBoxH8,
        TextFormField(
          controller: addressController,
          keyboardType: TextInputType.streetAddress,
          decoration: kTextFieldDecoration.copyWith(
              hintText: 'Write your address',
              // hintText: 'أكتب عنوانك',
              prefixIcon: const Icon(Icons.place_outlined),
          ),
        ),
        kSizeBoxH8,
        TextFormField(
          controller: mobileController,
          keyboardType: TextInputType.phone,
          decoration: kTextFieldDecoration.copyWith(
              hintText: 'Enter mobile number',
              // hintText: 'أدخل رقم جوالك',
              prefixIcon: const Icon(Icons.phone_android),
          ),
          // textAlign: TextAlign.right,
        ),
        kSizeBoxH8,
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: kTextFieldDecoration.copyWith(
              hintText: 'Write your email',
              // hintText: 'الإيميل',
              prefixIcon: const Icon(Icons.email)),
        ),
        kSizeBoxH8,
        TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: !isVisibleSignup,
          decoration: kTextFieldDecoration.copyWith(
            hintText: 'Write password',
            // hintText: 'كلمة المرور',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isVisibleSignup = !isVisibleSignup;
                });
              },
              icon: isVisibleSignup
                  ? const Icon(
                Icons.visibility,
                color: Colors.grey,
              )
                  : const Icon(
                Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        kSizeBoxH32,
        kSizeBoxH24,
        MainBtn(
          text: "Create Account",
          // text: "Signup",
          showProgress: showProgress,
          onPressed: () async {
            String name = nameController.text.trim().toString();
            String birthdate = birthdateController.text.trim().toString();
            String address = addressController.text.trim().toString();
            String mobile = mobileController.text.trim().toString();
            String email = emailController.text.trim().toString();
            String password = passwordController.text.trim().toString();

            if (name.isEmpty || birthdate.isEmpty || address.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
              var snackBar = const SnackBar(content: Text('Fill all fields !'));
              // var snackBar = const SnackBar(content: Text('إملأ جميع الخانات'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              if (password.length >= 6) {
                if(name.contains(" ")){
                  setState(() {
                    showProgress = true;
                  });
                  try{
                    await FbAuthentication.signUpWithEmailAndPassword(email, password);
                    if (mounted) {
                      UserModel user = UserModel(
                          imageUrl: null, name: name, email: email, address: address,
                          birthdate: birthdate, mobileNumber: mobile, role: UserRole.Patient.name,
                          token: "${SharedPreferenceHelper.getMyToken()}", subscribedTopics: [],
                      );
                      bool isCreated = await FbAuthentication.addNewPatient(context, user);
                      if(isCreated && mounted) {
                        FbActivitiesFunctions.createUserActivity(context, email);
                        Navigator.pushReplacementNamed(context, PageViewPatient.id);
                      }
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'invalid-email') {
                      var snackBar = const SnackBar(content: Text('Write valid email!'));
                      // var snackBar = const SnackBar(content: Text('هذا الإيميل غير صالح'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else if (e.code == 'email-already-in-use') {
                      var snackBar = const SnackBar(content: Text('This email has already been taken.'));
                      // var snackBar = const SnackBar(content: Text('هذا الإيميل مستخدم من قبل'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  } catch (e) {
                    var snackBar = SnackBar(content: Text('Error, $e'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }else{
                  var snackBar = const SnackBar(content: Text('Write your full name'));
                  // var snackBar = const SnackBar(content: Text('أكتب إسمك كامل'));
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
        kSizeBoxH8,
      ],
    );
  }
}
