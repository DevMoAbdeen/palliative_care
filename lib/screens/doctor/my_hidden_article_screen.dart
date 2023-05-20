import 'package:flutter/material.dart';
import 'package:palliative_care/models/user.dart';
import 'package:provider/provider.dart';
import '../../components/main_widgets.dart';
import '../../components/shimmers.dart';
import '../../firebase/fb_activity.dart';
import '../../firebase/fb_articles.dart';
import '../../firebase/fb_authentication.dart';
import '../../functions.dart';
import '../../models/article.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class MyHiddenArticleScreen extends StatefulWidget {
  const MyHiddenArticleScreen({Key? key}) : super(key: key);

  @override
  State<MyHiddenArticleScreen> createState() => _MyHiddenArticleScreenState();
}

class _MyHiddenArticleScreenState extends State<MyHiddenArticleScreen>  {
  TextEditingController searchController = TextEditingController();

  bool isGettingData = false;

  List<Article> myHiddenArticles = [];
  String articleSearchWritten = "";
  List<Article> articlesContainSearchValue = [];
  UserModel? currentUser;

  getData() async {
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }

    setState(() {
      isGettingData = true;
    });
    myHiddenArticles = await FbArticlesFunctions.getMyHiddenArticle(context, currentUser!.email);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      isGettingData = false;
    });
  }

  void deleteArticle(int index) {
    Article thisArticle = articleSearchWritten.isEmpty ? myHiddenArticles[index] : articlesContainSearchValue[index];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AllFunctions.showDialogDelete(context,
            deleteWhat: "Article",
            deleteFunction: () async {
              bool isDeleted = await FbArticlesFunctions.deleteArticle(context, thisArticle.articleId!);
              if(isDeleted){
                if (articleSearchWritten.isEmpty) {
                  myHiddenArticles.remove(thisArticle);
                } else {
                  articlesContainSearchValue.remove(thisArticle);
                  myHiddenArticles.remove(thisArticle);
                }
                FbActivitiesFunctions.handleArticleActivity(context, currentUser!.email,
                  thisArticle.title, DateTime.now().toString(), false,
                );
                setState(() {});
              }
              Navigator.pop(context);
            },
          );
        },
    );
  }

  @override
  void initState() {
    getData();
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
      resizeToAvoidBottomInset: false,
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
                    articleSearchWritten = value.trim();
                    articlesContainSearchValue = myHiddenArticles.where((element) =>
                    element.title.toUpperCase().contains(value.toUpperCase()) ||
                        element.description.toUpperCase().contains(value.toUpperCase()),
                    ).toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: "search a article...",
                  // hintText: "إبحث عن مقالة...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      searchController.clear();
                      articleSearchWritten = "";
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
              child: !isGettingData && myHiddenArticles.isEmpty
                  ? Center(child: Text("You do not have any hidden articles"))
                  : !isGettingData && articleSearchWritten.isNotEmpty && articlesContainSearchValue.isEmpty
              ? const Center(child: Text("No articles contain this word"))
                  // ? const Center(child: Text("لا يوجد مقالات تحتوي على هذه الكلمة"))
                  : ListView.builder(
                      itemCount: isGettingData
                          ? 5
                          : articleSearchWritten.isEmpty
                            ? myHiddenArticles.length
                            : articlesContainSearchValue.length,
                      itemBuilder: (context, index) {
                        return isGettingData
                            ? AllShimmerLoaded.shimmerArticle(context)
                            : ShowArticleInPost(
                                article: articleSearchWritten.isEmpty
                                    ? myHiddenArticles[index]
                                    : articlesContainSearchValue[index],
                                currentUser: currentUser!,
                                deleteArticle: () {
                                  deleteArticle(index);
                                },
                                unHideArticle: () async {
                                  Article thisArticle = articleSearchWritten.isEmpty ? myHiddenArticles[index] : articlesContainSearchValue[index];

                                  bool isHide = await FbArticlesFunctions.unHideArticle(context, thisArticle.articleId!, DateTime.now().toString());
                                  if(isHide) {
                                    if(articleSearchWritten.isEmpty){
                                      myHiddenArticles.remove(thisArticle);
                                    }else{
                                      articlesContainSearchValue.remove(thisArticle);
                                      myHiddenArticles.remove(thisArticle);
                                    }
                                    setState(() {});
                                  }
                                },
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
