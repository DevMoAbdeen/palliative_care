import 'package:flutter/material.dart';
import 'package:palliative_care/components/shimmers.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/screens/doctor/doctor_topics_screen.dart';
import 'package:palliative_care/screens/joint/chat.dart';
import 'package:provider/provider.dart';
import '../../components/contact_info.dart';
import '../../components/display_files.dart';
import '../../components/main_widgets.dart';
import '../../firebase/fb_authentication.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';
import '../joint/write_pass_bottom_sheet.dart';
import 'doctor_articles_screen.dart';
import '../joint/edit_data_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorEmail;
  final bool isFromPageView;

  const DoctorProfileScreen({Key? key, required this.doctorEmail, required this.isFromPageView}) : super(key: key);

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isGettingData = false;
  DoctorModel? doctor;
  UserModel? currentUser;

  getData() async {
    setState(() {
      isGettingData = true;
    });
    doctor = await FbAuthentication.getDoctorData(context, widget.doctorEmail);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      isGettingData = false;
    });
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

  void _openEditDataScreen() async {
    final updatedData = await Navigator.push(context, MaterialPageRoute(builder: (_) =>
        EditDataScreen(name: doctor!.name, email: doctor!.email, specialty: doctor!.specialty,
          address: doctor!.address, mobileNumber: doctor!.mobileNumber,
          birthdate: doctor!.birthdate, imageUrl: doctor!.imageUrl,
        ),
    ));

    if (updatedData != null) {
      await getData();
      // عشان يحفظ البيانات الجديدة في provider
      await FbAuthentication.getUserData(context, widget.doctorEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isGettingData
            ? AllShimmerLoaded.shimmerDoctorProfile()
            : doctor == null
                ? const Center(child: Text("This account may have been deleted!"))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            if (doctor!.imageUrl != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                  ShowImageScreen(uri: doctor!.imageUrl!, isWantDownload: false),
                              ));
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 3,
                            width: double.infinity,
                            decoration: doctor!.imageUrl != null
                                ? BoxDecoration(
                                    color: Colors.grey[400],
                                    image: DecorationImage(
                                      image: NetworkImage(doctor!.imageUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : BoxDecoration(color: Colors.grey[500],),
                            child: Stack(
                              children: [
                                widget.isFromPageView
                                    ? kSizeBoxEmpty
                                    : Positioned(
                                        top: 16,
                                        left: 16,
                                        child: CircleAvatar(
                                          backgroundColor: kMainColorDark,
                                          child: Center(
                                            child: IconButton(
                                              icon: const Icon(Icons.keyboard_backspace_outlined),
                                              color: Colors.white,
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: Text(
                                    doctor!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      backgroundColor: kMainColorDark,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor!.specialty,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              kSizeBoxH16,
                              Divider(color: Colors.grey[500], thickness: 1),
                              kSizeBoxH16,
                              Text(
                                'Contact Info',
                                // 'معلومات التواصل',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              kSizeBoxH16,
                              ContactInfoDoctor(
                                icon: Icons.email,
                                text: "Email",
                                // text: "الإيميل",
                                value: doctor!.email,
                              ),
                              ContactInfoDoctor(
                                icon: Icons.home,
                                text: "Address",
                                // text: "العنوان",
                                value: doctor!.address,
                              ),
                              ContactInfoDoctor(
                                icon: Icons.phone,
                                text: "Mobile Number",
                                // text: "رقم الجوال",
                                value: doctor!.mobileNumber,
                              ),
                              ContactInfoDoctor(
                                icon: Icons.calendar_today,
                                text: "Birthdate",
                                // text: "تاريخ الميلاد",
                                value: doctor!.birthdate,
                              ),
                              kSizeBoxH16,
                              currentUser!.email == doctor!.email
                                  ? MainBtn(
                                      text: "Edit your data",
                                      // text: "تعديل بياناتك",
                                      showProgress: false,
                                      onPressed: () {
                                        editDataBottomSheet(currentUser!.email);
                                      },
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                                  DoctorArticlesScreen(doctorEmail: doctor!.email),
                                              ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: kMainColorDark,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                              child: const Center(
                                                child: Text(
                                                  "Doctor Articles",
                                                  // "مقالات الدكتور",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        kSizeBoxW8,
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                                ChatScreen(
                                                  otherUserEmail: doctor!.email,
                                                  otherUserName: doctor!.name,
                                                  otherUserImage: doctor!.imageUrl,
                                                  otherUserRole: UserRole.Doctor.name,
                                                  otherUserToken: doctor!.token,
                                                ),
                                              ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: kMainColorDark,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                              child: const Center(
                                                child: Text(
                                                  "Send Message",
                                                  // "إرسال رسالة",
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        kSizeBoxW8,
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                  DoctorTopicsScreen(doctorEmail: doctor!.email),
                                              ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: kMainColorDark,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                              child: const Center(
                                                child: Text(
                                                  "Doctor Topics",
                                                  // "مواضيع الدكتور",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
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
