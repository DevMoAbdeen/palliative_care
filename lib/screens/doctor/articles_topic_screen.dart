import 'package:flutter/material.dart';
import 'package:palliative_care/components/main_widgets.dart';
import 'package:palliative_care/components/shimmers.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_activity.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/models/topic.dart';
import 'package:provider/provider.dart';
import '../../functions.dart';
import '../../firebase/fb_authentication.dart';
import '../../models/article.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class ArticlesTopicScreen extends StatefulWidget {
  final Topic topic;

  const ArticlesTopicScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<ArticlesTopicScreen> createState() => _ArticlesTopicScreenState();
}

class _ArticlesTopicScreenState extends State<ArticlesTopicScreen> {
  List<Article> articlesTopic = [];
  bool isGettingData = false;
  UserModel? currentUser;

  getData() async {
    setState(() {
      isGettingData = true;
    });
    articlesTopic = await FbArticlesFunctions.getArticlesTopic(context, widget.topic.topicId!);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isGettingData = false;
    });
  }

  Future<void> deleteArticle(int index) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AllFunctions.showDialogDelete(
            context,
            deleteWhat: "Article",
            deleteFunction: () async {
              bool isDeleted = await FbArticlesFunctions.deleteArticle(context, articlesTopic[index].articleId!);
              if(isDeleted){
                articlesTopic.removeAt(index);
                setState(() {});
                FbActivitiesFunctions.handleArticleActivity(context, currentUser!.email, articlesTopic[index].title, DateTime.now().toString(), false);
              }
              Navigator.pop(context);
            },
          );
        });
  }

  @override
  void initState() {
    currentUser =
        Provider.of<UserProvider>(context, listen: false).getCurrentUser;
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
      resizeToAvoidBottomInset: false,
      backgroundColor: kBackgroundColor,
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text("All articles in topic (${widget.topic.title}"),
                // child: Text("المقالات التابعة إلى الموضوع (${widget.topic.title})",
                //   style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                //   textAlign: TextAlign.center,
                // ),
              ),
            ],
          ),
          !isGettingData && articlesTopic.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text("No any articles in this topic"),
                    // child: Text("لا يوجد مقالات تابعة لهذا الموضوع"),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: isGettingData ? 5 : articlesTopic.length,
                    itemBuilder: (context, index) {
                      return isGettingData
                          ? AllShimmerLoaded.shimmerArticle(context)
                          : ShowArticleInPost(
                              article: articlesTopic[index],
                              currentUser: currentUser!,
                              deleteArticle: () {
                                deleteArticle(index);
                              },
                              deleteArticleFromAdmin: () {
                                deleteArticle(index);
                              },
                              hideArticle: () async {
                                bool isHide = await FbArticlesFunctions.hideArticle(context, articlesTopic[index].articleId!, DateTime.now().toString());
                                if(isHide) {
                                  articlesTopic.removeAt(index);
                                  setState(() {});
                                }
                              },
                            );
                    },
                  ),
                )
        ],
      ),
    );
  }
}
