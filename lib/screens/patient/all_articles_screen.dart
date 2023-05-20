import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/main_widgets.dart';
import '../../components/shimmers.dart';
import '../../constants.dart';
import '../../firebase/fb_activity.dart';
import '../../firebase/fb_articles.dart';
import '../../firebase/fb_authentication.dart';
import '../../functions.dart';
import '../../models/article.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class AllArticlesScreen extends StatefulWidget {
  static const String id = "HomeScreenPatient";

  const AllArticlesScreen({Key? key}) : super(key: key);

  @override
  State<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  List<Article> allArticles = [];
  bool isGettingData = false;
  UserModel? currentUser;

  getData() async {
    setState(() {
      isGettingData = true;
    });
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }

    allArticles = await FbArticlesFunctions.getAllArticles(context);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      isGettingData = false;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Align(
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Expanded(
              child: !isGettingData && allArticles.isEmpty
                  ? const Center(child: Text("No any articles yet"))
                  // ? const Center(child: Text("لا يوجد أي مقالات"))
                  : ListView.builder(
                      itemCount: isGettingData ? 5 : allArticles.length,
                      itemBuilder: (context, index) {
                        return isGettingData
                            ? AllShimmerLoaded.shimmerArticle(context)
                            : ShowArticleInPost(
                                article: allArticles[index],
                                currentUser: currentUser!,
                                deleteArticleFromAdmin: () {
                                  showDialog(context: context, builder: (BuildContext context) {
                                    return AllFunctions.showDialogDelete(
                                      context,
                                      deleteWhat: "Article",
                                      deleteFunction: () async {
                                        await FbArticlesFunctions.deleteArticle(context, allArticles[index].articleId!);
                                        Navigator.pop(context);
                                        allArticles.removeAt(index);
                                        FbActivitiesFunctions.handleArticleActivity(context, currentUser!.email,
                                            allArticles[index].title, DateTime.now().toString(), false);
                                        setState(() {});
                                      },
                                    );
                                  });
                                },
                              );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
