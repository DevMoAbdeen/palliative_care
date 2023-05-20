import 'package:flutter/material.dart';
import 'package:palliative_care/models/article.dart';
import 'package:provider/provider.dart';
import '../../components/main_widgets.dart';
import '../../components/shimmers.dart';
import '../../firebase/fb_activity.dart';
import '../../firebase/fb_articles.dart';
import '../../firebase/fb_authentication.dart';
import '../../functions.dart';
import '../../models/user.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class DoctorArticlesScreen extends StatefulWidget {
  final String doctorEmail;

  const DoctorArticlesScreen({Key? key, required this.doctorEmail}) : super(key: key);

  @override
  State<DoctorArticlesScreen> createState() => _DoctorArticlesScreenScreenState();
}

class _DoctorArticlesScreenScreenState extends State<DoctorArticlesScreen> {
  TextEditingController searchController = TextEditingController();

  bool isGettingData = false;

  List<Article> doctorArticles = [];
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
    doctorArticles = await FbArticlesFunctions.getDoctorsArticles(context, widget.doctorEmail);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      isGettingData = false;
    });
  }

  void deleteArticle(int index) {
    Article thisArticle = articleSearchWritten.isEmpty
        ? doctorArticles[index]
        : articlesContainSearchValue[index];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AllFunctions.showDialogDelete(
            context,
            deleteWhat: "Article",
            deleteFunction: () async {
              bool isDeleted = await FbArticlesFunctions.deleteArticle(context, thisArticle.articleId!);
              if(isDeleted){
                if (articleSearchWritten.isEmpty) {
                  doctorArticles.remove(thisArticle);
                } else {
                  articlesContainSearchValue.remove(thisArticle);
                  doctorArticles.remove(thisArticle);
                }
                FbActivitiesFunctions.handleArticleActivity(context, currentUser!.email,
                  thisArticle.title, DateTime.now().toString(), false,
                );
                setState(() {});
              }
              Navigator.pop(context);
            },
          );
        });
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
      appBar: widget.doctorEmail == currentUser!.email
          ? null
          : AppBar(title: Text("Articles ${widget.doctorEmail}")),
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
                    articlesContainSearchValue = doctorArticles.where((element) =>
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
              child: !isGettingData && doctorArticles.isEmpty
                  ? Center(
                      child: Text(widget.doctorEmail == currentUser!.email
                          ? "You did not create any articles yet"
                          : "This doctor did not create any articles yet"),
                          // ? "أنت لم تنشر أي مقالة من قبل"
                          // : "هذا الدكتور لم ينشر أي مقالة من قبل"),
                    )
                  : !isGettingData && articleSearchWritten.isNotEmpty && articlesContainSearchValue.isEmpty
                      ? const Center(child: Text("No articles contain this word"))
                      // ? const Center(child: Text("لا يوجد مقالات تحتوي على هذه الكلمة"))
                      : ListView.builder(
                          itemCount: isGettingData
                              ? 5
                              : articleSearchWritten.isEmpty
                                  ? doctorArticles.length
                                  : articlesContainSearchValue.length,
                          itemBuilder: (context, index) {
                            return isGettingData
                                ? AllShimmerLoaded.shimmerArticle(context)
                                : ShowArticleInPost(
                                    article: articleSearchWritten.isEmpty
                                        ? doctorArticles[index]
                                        : articlesContainSearchValue[index],
                                    currentUser: currentUser!,
                                    deleteArticle: () {
                                      deleteArticle(index);
                                    },
                                    deleteArticleFromAdmin: () {
                                      deleteArticle(index);
                                    },
                                    hideArticle: () async {
                                      Article thisArticle = articleSearchWritten.isEmpty ? doctorArticles[index] : articlesContainSearchValue[index];
                                      bool isHide = await FbArticlesFunctions.hideArticle(context, thisArticle.articleId!, DateTime.now().toString());
                                      if(isHide) {
                                        if(articleSearchWritten.isEmpty){
                                          doctorArticles.remove(thisArticle);
                                        }else{
                                          articlesContainSearchValue.remove(thisArticle);
                                          doctorArticles.remove(thisArticle);
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
