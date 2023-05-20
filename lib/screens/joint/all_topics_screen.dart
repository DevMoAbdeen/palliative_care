import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/components/shimmers.dart';
import 'package:palliative_care/firebase/fb_activity.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../firebase/fb_authentication.dart';
import '../../firebase/fb_topics.dart';
import '../../functions.dart';
import '../../models/topic.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';
import '../doctor/articles_topic_screen.dart';

class AllTopicsScreen extends StatefulWidget {
  static const String id = "AllTopicsScreen";

  const AllTopicsScreen({Key? key}) : super(key: key);

  @override
  State<AllTopicsScreen> createState() => _AllTopicsScreenState();
}

class _AllTopicsScreenState extends State<AllTopicsScreen> {
  TextEditingController searchController = TextEditingController();
  String topicNameWritten = "";
  List<Topic> topicsContainName = [];
  List<Topic> allTopics = [];
  UserModel? currentUser;

  bool isGettingData = false;

  getAllTopics() async {
    setState(() {
      isGettingData = true;
    });

    allTopics = await FbTopicsFunctions.getAllTopics(context);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isGettingData = false;
    });
  }

  showNotification(bool subscribed, String topicTitle) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: subscribed ? 1 : 2,
          channelKey: subscribedTopicChannel,
          title: subscribed ? "Subscribed Topic" : "Unsubscribed Topic",
          // title: subscribed ? "الإشتراك بالموضوع" : "إلغاء الإشتراك بالموضوع",
          body: subscribed
              ? "You will receive a notification when any article published to topic ($topicTitle)"
              : "You will no longer receive a notification regarding topic ($topicTitle)",
              // ? "سوف تتلقى إشعارات عند نشر أي مقال بخصوص الموضوع ($topicTitle)"
              // : "ألغيت إشتاكك بالموضوع ($topicTitle)",
          notificationLayout: NotificationLayout.Default,
      ),
    );
    FbActivitiesFunctions.handleSubscribedTopicActivity(context,
        currentUser!.email, topicTitle, DateTime.now().toString(), subscribed);
  }

  @override
  void initState() {
    // AwesomeNotifications().setListeners(
    //     onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    //     onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
    //     onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
    //     onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    // );

    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });

    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }
    getAllTopics();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: !isGettingData && allTopics.isEmpty
          ? const Center(child: Text("No any topics created yet"))
          // ? const Center(child: Text("لا يوجد أي مواضيع"))
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      topicNameWritten = value;
                      topicsContainName = allTopics.where((element) =>
                          (element.title.toUpperCase().contains(value.toUpperCase()) ||
                            element.description.toUpperCase().contains(value.toUpperCase())),
                      ).toList();
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Search a topic...",
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
                kSizeBoxH8,
                Expanded(
                  child: !isGettingData && topicNameWritten.isNotEmpty && topicsContainName.isEmpty
                      ? const Center(child: Text("No topics contain this word"))
                      // ? const Center(child: Text("لا يوجد مواضيع تحتوي على هذه الكلمة"))
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
                                          ArticlesTopicScreen(topic: topicNameWritten.isEmpty ? allTopics[index] : topicsContainName[index]),
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
                                            onPressed: () async {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AllFunctions.showDialogDelete(
                                                      context,
                                                      deleteWhat: "Topic",
                                                      deleteFunction: () async {
                                                        await FbTopicsFunctions.deleteTopic(
                                                            context,
                                                            topicNameWritten.isEmpty
                                                                ? allTopics[index].topicId!
                                                                : topicsContainName[index].topicId!);
                                                        if (topicNameWritten.isEmpty) {
                                                          allTopics.removeAt(index);
                                                        } else {
                                                          topicsContainName.removeAt(index);
                                                          allTopics.remove(topicsContainName[index]);
                                                        }
                                                        setState(() {});
                                                        Navigator.pop(
                                                            context);
                                                      },
                                                    );
                                                  });
                                            },
                                            icon: const Icon(Icons.delete_forever),
                                          )
                                        : topicNameWritten.isEmpty
                                            ? currentUser!.subscribedTopics.contains(allTopics[index].topicId)
                                                ? IconButton(
                                                    onPressed: () async {
                                                      bool isHandle = await FbAuthentication.handleSubscribedTopic(
                                                          context, currentUser!.email, allTopics[index].topicId!, false,
                                                      );
                                                      if (isHandle) {
                                                        currentUser!.subscribedTopics.remove(allTopics[index].topicId);
                                                        showNotification(false, allTopics[index].title);
                                                        setState(() {});
                                                      }
                                                    },
                                                    icon: const Icon(
                                                        Icons.notifications_active,
                                                        color: kMainColorLight,
                                                    ),
                                                )
                                                : IconButton(
                                                    onPressed: () async {
                                                      bool isHandle = await FbAuthentication.handleSubscribedTopic(
                                                          context, currentUser!.email, allTopics[index].topicId!, true,
                                                      );
                                                      if (isHandle) {
                                                        currentUser!.subscribedTopics.add(allTopics[index].topicId);
                                                        showNotification(true, allTopics[index].title);
                                                        setState(() {});
                                                      }
                                                    },
                                                    icon: const Icon(Icons.notifications_off),
                                                )
                                            : currentUser!.subscribedTopics.contains(topicsContainName[index].topicId)
                                                ? IconButton(
                                                    onPressed: () async {
                                                      bool isHandle = await FbAuthentication.handleSubscribedTopic(
                                                          context, currentUser!.email, topicsContainName[index].topicId!, false);
                                                      if (isHandle) {
                                                        currentUser!.subscribedTopics.remove(topicsContainName[index].topicId);
                                                        showNotification(false, topicsContainName[index].title);
                                                        setState(() {});
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.notifications_active,
                                                      color: kMainColorLight,
                                                    ),
                                                )
                                                : IconButton(
                                                    onPressed: () async {
                                                      bool isHandle = await FbAuthentication.handleSubscribedTopic(
                                                          context, currentUser!.email, topicsContainName[index].topicId!, true);
                                                      if (isHandle) {
                                                        currentUser!.subscribedTopics.add(topicsContainName[index].topicId);
                                                        showNotification(true, topicsContainName[index].title);
                                                        setState(() {});
                                                      }
                                                    },
                                                    icon: const Icon(Icons.notifications_off),
                                               ),
                                );
                          },
                        ),
                )
              ],
            ),
    ));
  }
}
