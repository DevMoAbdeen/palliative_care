import 'package:flutter/material.dart';
import 'package:palliative_care/components/shimmers.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_activity.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/firebase/fb_comments.dart';
import '../../firebase/fb_chat.dart';
import '../../functions.dart';
import '../../models/user.dart';

class ShowAllUsers extends StatefulWidget {
  const ShowAllUsers({Key? key}) : super(key: key);

  @override
  State<ShowAllUsers> createState() => _ShowAllUsersState();
}

class _ShowAllUsersState extends State<ShowAllUsers> {
  TextEditingController searchController = TextEditingController();
  String userNameWritten = "";

  late List<UserModel> allUsers;
  late List<UserModel> usersContainSearchValue;
  bool isProcessRunning = false;
  late BuildContext thisContext;

  getAllUsers() async {
    setState(() {
      isProcessRunning = true;
    });
    allUsers = await FbChat.getAllUsers(context);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      isProcessRunning = false;
    });
  }

  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    thisContext = context;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: isProcessRunning
            ? ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => AllShimmerLoaded.shimmerAllUsers(),
              )
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          userNameWritten = value;
                          usersContainSearchValue = allUsers.where((element) =>
                            element.name.toUpperCase().contains(value.toUpperCase()) ||
                            element.email.contains(value)
                          ).toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "search a user...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            searchController.clear();
                            userNameWritten = "";
                            setState(() {});
                          },
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userNameWritten.isEmpty
                          ? allUsers.length
                          : usersContainSearchValue.length,
                      itemBuilder: (context, index) {
                        UserModel user = userNameWritten.isEmpty
                            ? allUsers[index]
                            : usersContainSearchValue[index];
                        return ListTile(
                          onTap: () {
                            // FbChat.deleteUserMessages(context, allUsers[index].email);
                          },
                          leading: user.imageUrl != null
                              ? Hero(
                                  tag: user.imageUrl!,
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey.shade400,
                                    backgroundImage: NetworkImage(user.imageUrl!),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 25,
                                  backgroundColor: kMainColorLight,
                                  child: Center(
                                    child: Text(
                                      AllFunctions.getFirstLetter(user.name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                          title: user.role == UserRole.Doctor.name
                              ? Text("Dr. ${user.name}")
                              : Text(user.name),
                          subtitle: Text(user.email),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AllFunctions.showDialogDelete(
                                    context,
                                    deleteWhat: "User",
                                    deleteFunction: () async {
                                      Navigator.pop(context);
                                      setState(() {
                                        isProcessRunning = true;
                                      });
                                      bool isDeleted = await FbAuthentication.deleteUser(thisContext, user.email);
                                      if (isDeleted) {
                                        ScaffoldMessenger.of(thisContext).showSnackBar(const SnackBar(
                                          content: Text('User has been deleted, He will not be able to log into his account again'),
                                        ));

                                        if (userNameWritten.isEmpty) {
                                          allUsers.remove(user);
                                        } else {
                                          usersContainSearchValue.remove(user);
                                          allUsers.remove(user);
                                        }
                                        if (user.role == UserRole.Doctor.name) {
                                          FbArticlesFunctions.deleteDoctorArticles(thisContext, user.email);
                                        }
                                        FbActivitiesFunctions.deleteUserActivity(thisContext, user.email);
                                        FbCommentsFunctions.deleteUserComments(thisContext, user.email);
                                      } else {
                                        ScaffoldMessenger.of(thisContext).showSnackBar(const SnackBar(
                                          content: Text('Something went wrong, retry again'),
                                        ));
                                      }
                                      setState(() {
                                        isProcessRunning = false;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
