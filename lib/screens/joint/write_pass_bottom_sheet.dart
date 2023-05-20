import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/main_widgets.dart';
import '../../constants.dart';
import '../../firebase/fb_authentication.dart';

class WritePasswordBottomSheet extends StatefulWidget {
  final String email;
  final Function openEditDataScreen;

  const WritePasswordBottomSheet({Key? key, required this.email, required this.openEditDataScreen}) : super(key: key);

  @override
  State<WritePasswordBottomSheet> createState() => _WritePasswordBottomSheetState();
}

class _WritePasswordBottomSheetState extends State<WritePasswordBottomSheet> {
  TextEditingController passwordController = TextEditingController();
  bool isCLickEditData = false;
  String? passwordValidation;
  bool isVisibleSignup = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isCLickEditData
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Padding(
              // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !isVisibleSignup,
                          decoration: InputDecoration(
                            labelText: "Enter your password",
                            // labelText: "أكتب كلمة المرور",
                            errorText: passwordValidation,
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
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
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                passwordValidation = null;
                              });
                            }
                          },
                        ),
                      ),
                      kSizeBoxH32,
                      MainBtn(
                        text: "Edit your data",
                        showProgress: false,
                        onPressed: () async {
                          String password =
                              passwordController.text.toString().trim();
                          if (password.isNotEmpty && password.length >= 6) {
                            setState(() {
                              isCLickEditData = true;
                            });
                            try {
                              final thisUser = await FbAuthentication.loginWithEmailAndPassword(widget.email, password);
                              if (thisUser.user != null && mounted) {
                                Navigator.pop(context);
                                widget.openEditDataScreen();
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'wrong-password') {
                                setState(() {
                                  passwordValidation = "The password is wrong!";
                                  // passwordValidation = "كلمة المرور خاطئة";
                                });
                              }
                            } catch (e) {
                              var snackBar = SnackBar(content: Text('Error, $e'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                            setState(() {
                              isCLickEditData = false;
                            });
                          } else {
                            setState(() {
                              passwordValidation = password.isEmpty
                                  ? "Write your password!"
                                  : "The password is short, it must be longer than 5 characters";
                                  // ? "أكتب كلمة المرور"
                                  // : "كلمة المرور قصيرة, يجب ان تكون أطول من 5 حروف";
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
