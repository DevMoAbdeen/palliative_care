import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/screens/authentication/login_and_signup_screen.dart';
import 'package:palliative_care/statemanagment/provider_user.dart';
import 'package:provider/provider.dart';
import '../../components/display_files.dart';
import '../../components/shimmers.dart';
import '../../firebase/fb_authentication.dart';
import '../../firebase/fb_chat.dart';
import '../../functions.dart';
import 'chat.dart';

class AllUsersScreen extends StatefulWidget {
  static const String id = "AllUsersScreen";

  const AllUsersScreen({Key? key}) : super(key: key);

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  late List<UserModel> allUsers;
  bool isGetData = false;
  UserModel? currentUser;

  getAllUsers() async {
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }

    allUsers = await FbChat.getAllUsers(context);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      isGetData = true;
    });
  }

  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // backgroundColor: Colors.grey[400],
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: "Doctors"),
              // Tab(text: "الدكاترة"),
              Tab(text: "Patients"),
              // Tab(text: "المرضى"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            if (isGetData) ...{
              UserData(
                allUsers: allUsers.where((element) => element.role == UserRole.Doctor.name && currentUser!.email != element.email).toList(),
                role: UserRole.Doctor.name,
              ),
              UserData(
                allUsers: allUsers.where((element) => element.role == UserRole.Patient.name && currentUser!.email != element.email).toList(),
                role: UserRole.Patient.name,
              ),
            } else ...{
              ListView.builder(
                shrinkWrap: false,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return AllShimmerLoaded.shimmerAllUsers();
                },
              ),
              ListView.builder(
                shrinkWrap: false,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return AllShimmerLoaded.shimmerAllUsers();
                },
              )
            }
          ],
        ),
      ),
    );
  }
}

class UserData extends StatelessWidget {
  final List<UserModel> allUsers;
  final String role;

  const UserData({Key? key, required this.allUsers, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return allUsers.isEmpty
        ? Center(
            child: Text(
              role == UserRole.Doctor.name
                  ? "No any Doctors yet"
                  : 'No any Patients yet',
                  // ? "لا يوجد أي دكاترة"
                  // : 'لا يوجد أي مرضى',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      ChatScreen(
                        otherUserEmail: allUsers[index].email,
                        otherUserName: allUsers[index].name,
                        otherUserImage: allUsers[index].imageUrl,
                        otherUserRole: role,
                        otherUserToken: allUsers[index].token,
                      ),
                  ));
                },
                leading: allUsers[index].imageUrl != null
                    ? InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) =>
                              ShowImageScreen(uri: allUsers[index].imageUrl!, isWantDownload: false)
                          ));
                        },
                        child: Hero(
                          tag: allUsers[index].imageUrl!,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade400,
                            backgroundImage: NetworkImage(allUsers[index].imageUrl!),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundColor: kMainColorLight,
                        child: Center(
                          child: Text(
                            AllFunctions.getFirstLetter(allUsers[index].name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                title: Text(
                  allUsers[index].name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  allUsers[index].email,
                ),
              );
            },
          );
  }
}
