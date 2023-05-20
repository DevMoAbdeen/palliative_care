import 'package:flutter/material.dart';
import 'package:palliative_care/components/main_widgets.dart';
import 'package:palliative_care/components/shimmers.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/models/article.dart';
import 'package:palliative_care/models/user.dart';
import 'package:provider/provider.dart';
import '../../firebase/fb_activity.dart';
import '../../firebase/fb_authentication.dart';
import '../../functions.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class ArticleActivityScreen extends StatefulWidget {
  final String articleId;

  const ArticleActivityScreen({Key? key, required this.articleId}) : super(key: key);

  @override
  State<ArticleActivityScreen> createState() => _ArticleActivityScreenState();
}

class _ArticleActivityScreenState extends State<ArticleActivityScreen> {
  Article? article;
  UserModel? currentUser;
  bool isGettingArticle = false;

  getArticle() async {
    setState(() {
      isGettingArticle = true;
    });
    article = await FbArticlesFunctions.getOneArticle(context, widget.articleId);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isGettingArticle = false;
    });
  }

  void deleteArticle() {
    showDialog(context: context, builder: (BuildContext context) {
      return AllFunctions.showDialogDelete(
        context,
        deleteWhat: "Article",
        deleteFunction: () async {
          await FbArticlesFunctions.deleteArticle(context, article!.articleId!);
          FbActivitiesFunctions.handleArticleActivity(context, currentUser!.email, article!.title, DateTime.now().toString(), false);
          Navigator.pop(context);
          setState(() {
            article = null;
          });
        },
      );
    });
  }

  @override
  void initState() {
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }

    getArticle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(),
      body: SafeArea(
        child: isGettingArticle
            ? AllShimmerLoaded.shimmerArticle(context)
            : article == null
                ? const Center(child: Text("This article may have been deleted"))
                : ListView(
                    children: [
                      ShowArticleInPost(
                        article: article!,
                        currentUser: currentUser!,
                        deleteArticle: () {
                          deleteArticle();
                        },
                        deleteArticleFromAdmin: () {
                          deleteArticle();
                        },
                        hideArticle: () async {
                          await FbArticlesFunctions.hideArticle(context, article!.articleId!, DateTime.now().toString());
                        },
                        unHideArticle: () async {
                          await FbArticlesFunctions.unHideArticle(context, article!.articleId!, DateTime.now().toString());
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}
