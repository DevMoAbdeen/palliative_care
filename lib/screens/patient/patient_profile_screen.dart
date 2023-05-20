import 'package:flutter/material.dart';
import 'package:palliative_care/components/main_widgets.dart';
import 'package:palliative_care/components/shimmers.dart';
import 'package:palliative_care/functions.dart';
import 'package:provider/provider.dart';
import '../../components/contact_info.dart';
import '../../components/display_files.dart';
import '../../constants.dart';
import '../../firebase/fb_authentication.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';
import '../joint/edit_data_screen.dart';
import '../joint/chat.dart';
import '../joint/write_pass_bottom_sheet.dart';

class PatientProfileScreen extends StatefulWidget {
  final String email;
  final bool isFromPageView;

  const PatientProfileScreen({super.key, required this.email, required this.isFromPageView});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool isGettingData = false;
  UserModel? patient;
  UserModel? currentUser;

  getData() async {
    setState(() {
      isGettingData = true;
    });
    patient = await FbAuthentication.getPatientData(context, widget.email);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isGettingData = false;
    });
  }

  void _openEditDataScreen() async {
    final updatedData = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
        EditDataScreen(
          name: patient!.name,
          email: patient!.email,
          specialty: null,
          address: patient!.address,
          mobileNumber: patient!.mobileNumber,
          birthdate: patient!.birthdate,
          imageUrl: patient!.imageUrl,
        ),
    ));

    if (updatedData != null) {
      await getData();
      // عشان يحفظ البيانات الجديدة في provider
      await FbAuthentication.getUserData(context, patient!.email);
    }
  }

  @override
  void initState() {
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }

    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFromPageView
          ? null
          : AppBar(
              title: widget.email == currentUser!.email
                  ? const Text("My Profile")
                  : const Text("Patient Profile"),
            ),
      body: isGettingData
          ? AllShimmerLoaded.shimmerPatientProfile()
          : patient == null
              ? const Center(child: Text("This account have been deleted !"))
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // if (MediaQuery.of(context).size.width > 500)...{}
                        // else ...{},
                        kSizeBoxH16,
                        patient!.imageUrl != null
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                      ShowImageScreen(uri: patient!.imageUrl!, isWantDownload: false)
                                  ));
                                },
                                child: CircleAvatar(
                                    radius: 80,
                                    backgroundImage: NetworkImage(patient!.imageUrl!),
                                ),
                              )
                            : CircleAvatar(
                                radius: 80,
                                backgroundColor: kMainColorLight,
                                child: Center(
                                  child: Text(
                                    AllFunctions.getFirstLetter(patient!.name),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                        kSizeBoxH16,
                        Text(
                          patient!.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        kSizeBoxH16,
                        Divider(color: Colors.grey[400], thickness: 1),
                        ListTile(
                          leading: Text(
                            'Contact Info',
                            // 'معلومات التواصل',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ContactInfoPatient(
                          icon: Icons.email,
                          text: "Email",
                          // text: "الإيميل",
                          value: patient!.email,
                        ),
                        ContactInfoPatient(
                          icon: Icons.home,
                          text: "Address",
                          // text: "العنوان",
                          value: patient!.address,
                        ),
                        ContactInfoPatient(
                          icon: Icons.phone,
                          text: "Mobile Number",
                          // text: "رقم الجوال",
                          value: patient!.mobileNumber,
                        ),
                        ContactInfoPatient(
                          icon: Icons.calendar_today,
                          text: "Birthdate",
                          // text: "تاريخ الميلاد",
                          value: patient!.birthdate,
                        ),
                        currentUser!.email == patient!.email
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: MainBtn(
                                  text: "Edit your data",
                                  // text: "تعديل بياناتك",
                                  showProgress: false,
                                  onPressed: () {
                                    editDataBottomSheet(currentUser!.email);
                                  },
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16),
                                child: MainBtn(
                                  text: "Send Message",
                                  // text: "إرسال رسالة",
                                  showProgress: false,
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                        ChatScreen(
                                          otherUserEmail: patient!.email,
                                          otherUserName: patient!.name,
                                          otherUserImage: patient!.imageUrl,
                                          otherUserRole: UserRole.Patient.name,
                                          otherUserToken: patient!.token,
                                        ),
                                    ));
                                  },
                                ),
                              )
                      ],
                    ),
                  ),
                ),
    );
  }

  void editDataBottomSheet(String email) {
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return FractionallySizedBox(
              heightFactor: 0.55,
              child: WritePasswordBottomSheet(email: email, openEditDataScreen: _openEditDataScreen),
            );
          },
        );
      },
    );
  }
}
