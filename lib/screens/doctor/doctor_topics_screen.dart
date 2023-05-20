import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/firebase/fb_notification.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/statemanagment/provider_user.dart';
import 'package:provider/provider.dart';
import '../../components/shimmers.dart';
import '../../firebase/fb_topics.dart';
import '../../functions.dart';
import '../../models/topic.dart';
import '../../statemanagment/provider_topics.dart';
import '../authentication/login_and_signup_screen.dart';
import 'articles_topic_screen.dart';

class DoctorTopicsScreen extends StatefulWidget {
  final String doctorEmail;

  const DoctorTopicsScreen({Key? key, required this.doctorEmail}) : super(key: key);

  @override
  State<DoctorTopicsScreen> createState() => _DoctorTopicsScreenState();
}

class _DoctorTopicsScreenState extends State<DoctorTopicsScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController topicNameController = TextEditingController();
  TextEditingController topicDescriptionController = TextEditingController();


  String topicNameWritten = "";
  List<Topic> allTopics = [];
  List<Topic> topicsContainName = [];
  bool isGettingData = false;
  bool isClickDelete = false;
  UserModel? currentUser;

  getMyTopics() async {
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }
    setState(() {
      isGettingData = true;
    });

    allTopics = Provider.of<TopicsProvider>(context, listen: false).getAllTopics
        .where((element) => element.doctorEmailCreated == widget.doctorEmail).toList();
    allTopics.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (allTopics.isEmpty) {
      allTopics = await FbTopicsFunctions.getMyTopics(context, widget.doctorEmail);
    }
    setState(() {
      isGettingData = false;
    });
  }

  void deleteTopic(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AllFunctions.showDialogDelete(
            context,
            deleteWhat: "Article",
            deleteFunction: () async {
              setState(() {
                isClickDelete = true;
              });
              bool isDeleted = await FbTopicsFunctions.deleteTopic(
                context,
                topicNameWritten.isEmpty
                    ? allTopics[index].topicId!
                    : topicsContainName[index].topicId!,
              );
              if(isDeleted) {
                Provider.of<TopicsProvider>(context, listen: false).deleteTopic(
                    topicNameWritten.isEmpty
                        ? allTopics[index]
                        : topicsContainName[index],
                );
                setState(() {
                  isClickDelete = false;
                });
              }
            },
          );
        });
  }

  @override
  void initState() {
    getMyTopics();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    topicNameController.dispose();
    topicDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: widget.doctorEmail == currentUser!.email
          ? null
          : AppBar(title: Text("Topics ${widget.doctorEmail}")),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    topicNameWritten = value.toString().trim();
                    topicsContainName = allTopics.where((element) =>
                        element.title.toUpperCase().contains(topicNameWritten.toUpperCase()) ||
                        element.description.toUpperCase().contains(topicNameWritten.toUpperCase())
                    ).toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: "search a topic...",
                  // hintText: "إبحث عن موضوع...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      searchController.clear();
                      topicNameWritten = "";
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
              child: !isGettingData && allTopics.isEmpty
                  ? Center(
                      child: Text(widget.doctorEmail == currentUser!.email
                          ? "You did not create any topics yet"
                          : "This doctor did not create any topics yet"),
                          // ? "أنت لم تنشر أي موضوع من قبل"
                          // : "هذا الدكتور لم ينشر أي موضوع من قبل"),
                    )
                  : !isGettingData &&
                          topicNameWritten.isNotEmpty &&
                          topicsContainName.isEmpty
                      ? const Center(child: Text("No any topics contain this word"))
                      // ? const Center(child: Text("لا يوجد أي موضوع يحتوي على هذه الكلمة"))
                      : ListView.builder(
                          itemCount: isGettingData
                              ? 10
                              : topicNameWritten.isEmpty
                                  ? allTopics.length
                                  : topicsContainName.length,
                          itemBuilder: (context, index) {
                            return isGettingData
                                ? AllShimmerLoaded.shimmerAllUsers()
                                : ListTile(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                          ArticlesTopicScreen(
                                              topic: topicNameWritten.isEmpty
                                                  ? allTopics[index]
                                                  : topicsContainName[index],
                                          ),
                                      ));
                                    },
                                    leading: const Icon(Icons.category),
                                    title: Text(
                                      topicNameWritten.isEmpty
                                          ? allTopics[index].title.toString()
                                          : topicsContainName[index].title,
                                    ),
                                    subtitle: Text(
                                      topicNameWritten.isEmpty
                                          ? allTopics[index].description
                                          : topicsContainName[index].description,
                                    ),
                                    trailing: currentUser!.role == UserRole.Admin.name
                                        ? IconButton(
                                            onPressed: () {
                                              deleteTopic(index);
                                            },
                                            icon: Icon(Icons.delete_forever))
                                        : widget.doctorEmail == currentUser!.email
                                            ? PopupMenuButton<int>(
                                                itemBuilder: (context) => [
                                                  AllFunctions.createPopupMenuItem(1, "Update", Icons.update),
                                                  AllFunctions.createPopupMenuItem(2, "Delete", Icons.delete_forever),
                                                ],
                                                onSelected: (value) async {
                                                  switch (value) {
                                                    case 1:{
                                                      topicNameWritten.isEmpty
                                                          ? updateTopicBottomSheet(allTopics[index])
                                                          : updateTopicBottomSheet(topicsContainName[index]);
                                                    }
                                                    break;

                                                    case 2:{
                                                      deleteTopic(index);
                                                    }
                                                    break;
                                                  }
                                                },
                                              )
                                            : kSizeBoxEmpty,
                                  );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void updateTopicBottomSheet(Topic topic) {
    topicNameController.text = topic.title;
    topicDescriptionController.text = topic.description;
    bool topicNameValidate = false;
    bool topicDescriptionValidate = false;
    bool isUpdated = false;

    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return FractionallySizedBox(
              heightFactor: 0.55,
              child: isUpdated
                  ? const Center(child: CircularProgressIndicator())
                  : Scaffold(
                      body: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Cancel",
                                    // "إلغاء",
                                    style: TextStyle(color: Colors.blue, fontSize: 16),
                                  ),
                                ),
                                TextButton(
                                  child: const Text(
                                    "Update Topic",
                                    // "تحديث الموضوع",
                                    style: TextStyle(color: Colors.blue, fontSize: 16),
                                  ),
                                  onPressed: () async {
                                    String newTopicName = topicNameController.text.trim();
                                    String newTopicDescription = topicDescriptionController.text.trim();
                                    if (newTopicName.isEmpty || newTopicDescription.isEmpty) {
                                      setStateBottomSheet(() {
                                        topicNameValidate = newTopicName.isEmpty;
                                        topicDescriptionValidate = newTopicDescription.isEmpty;
                                      });
                                    } else {
                                      setStateBottomSheet(() {
                                        isUpdated = true;
                                      });

                                      bool isUpdatedTopic = await FbTopicsFunctions.updateTopic(context, topic.topicId!,
                                          newTopicName, newTopicDescription, DateTime.now().toString(),
                                      );
                                      Provider.of<TopicsProvider>(context, listen: false).updateTopic(topic, newTopicName,
                                          newTopicDescription, DateTime.now().toString(),
                                      );
                                      setState(() {});
                                      setStateBottomSheet(() {
                                        isUpdated = false;
                                      });
                                      if (isUpdatedTopic) {
                                        FbNotificationFunctions.sendNotificationUpdatedTopic(topic.topicId!, newTopicName, topic.doctorEmailCreated);
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: TextField(
                              controller: topicNameController,
                              decoration: InputDecoration(
                                labelText: "New topic name",
                                // labelText: "الإسم الجديد للموضوع",
                                errorText: topicNameValidate
                                    ? 'Topic title can\'t be empty'
                                    // ? 'لا يمكن أن يكون الإسم فارغ'
                                    : null,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setStateBottomSheet(() {
                                    topicNameValidate = false;
                                  });
                                }
                              },
                            ),
                          ),
                          kSizeBoxH24,
                          Container(
                            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: TextField(
                              controller: topicDescriptionController,
                              decoration: InputDecoration(
                                // labelText: "الوصف الجديد للموضوع",
                                labelText: "New topic description",
                                errorText: topicDescriptionValidate
                                    ? 'Write description !'
                                    // ? 'أكتب وصف الموضوع !'
                                    : null,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setStateBottomSheet(() {
                                    topicDescriptionValidate = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
