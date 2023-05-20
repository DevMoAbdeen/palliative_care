import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_activity.dart';
import 'package:palliative_care/functions.dart';
import 'package:palliative_care/models/activity.dart';
import 'package:palliative_care/screens/joint/article_activity_screen.dart';
import 'package:provider/provider.dart';
import '../../components/shimmers.dart';
import '../../firebase/fb_authentication.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class YourActivityScreen extends StatefulWidget {
  const YourActivityScreen({Key? key}) : super(key: key);

  @override
  State<YourActivityScreen> createState() => _YourActivityScreenState();
}

class _YourActivityScreenState extends State<YourActivityScreen> {
  bool isGetData = false;
  Map<String, dynamic> allActivities = {};
  List<Like> likesActivity = [];
  List<Comment> commentsActivity = [];
  List<Other> othersActivity = [];
  UserModel? currentUser;

  getData() async {
    allActivities = await FbActivitiesFunctions.getUserActivities(context, currentUser!.email);
    dataClassification();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isGetData = true;
    });
  }

  dataClassification() {
    if (allActivities[ActivityType.Likes.name] != null) {
      for (var like in allActivities[ActivityType.Likes.name]) {
        likesActivity.add(Like.fromMap(like));
      }
      likesActivity = likesActivity.reversed.toList();
    }

    if (allActivities[ActivityType.Comments.name] != null) {
      for (var comment in allActivities[ActivityType.Comments.name]) {
        commentsActivity.add(Comment.fromMap(comment));
      }
      commentsActivity = commentsActivity.reversed.toList();
    }

    if (allActivities[ActivityType.Others.name] != null) {
      for (var other in allActivities[ActivityType.Others.name]) {
        othersActivity.add(Other.fromMap(other));
      }
      othersActivity = othersActivity.reversed.toList();
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: "Likes"),
              // Tab(text: "الإعجابات"),
              Tab(text: "Comments"),
              // Tab(text: "التعليقات"),
              Tab(text: "Others"),
              // Tab(text: "أخرى"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            isGetData && likesActivity.isEmpty
                ? const Center(child: Text("You have not liked any article before"))
                // ? const Center(child: Text("لم تضع إعجاب على أي مقالة من قبل"))
                : ListView.builder(
                    itemCount: isGetData ? likesActivity.length : 10,
                    itemBuilder: (context, index) {
                      return !isGetData
                          ? AllShimmerLoaded.shimmerActivity()
                          : InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    ArticleActivityScreen(articleId: likesActivity[index].articleId),
                                ));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      likesActivity[index].description,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    kSizeBoxH8,
                                    Text(AllFunctions.convertDate(likesActivity[index].date)),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
            isGetData && commentsActivity.isEmpty
                ? const Center(
                    child: Text("You have not commented on any article before"))
                    // child: Text("لم تقم بالتعليق على أي مقالة من قبل"))
                : ListView.builder(
                    itemCount: isGetData ? commentsActivity.length : 10,
                    itemBuilder: (context, index) {
                      return !isGetData
                          ? AllShimmerLoaded.shimmerActivity()
                          : InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    ArticleActivityScreen(articleId: commentsActivity[index].articleId),
                                ));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      commentsActivity[index].description,
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    kSizeBoxH8,
                                    Text(AllFunctions.convertDate(commentsActivity[index].date)),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
            isGetData && othersActivity.isEmpty
                ? const Center(child: Text("No any data"))
                // ? const Center(child: Text("لا يوجد أي بيانات"))
                : ListView.builder(
                    itemCount: isGetData ? othersActivity.length : 10,
                    itemBuilder: (context, index) {
                      return !isGetData
                          ? AllShimmerLoaded.shimmerActivity()
                          : InkWell(
                              onTap: () {},
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      othersActivity[index].description,
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    kSizeBoxH8,
                                    Text(AllFunctions.convertDate(othersActivity[index].date)),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
