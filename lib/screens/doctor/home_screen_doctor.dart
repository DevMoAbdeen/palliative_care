import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/models/article.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/statemanagment/provider_user.dart';
import 'package:provider/provider.dart';
import '../../components/main_widgets.dart';
import '../../components/shimmers.dart';
import '../../firebase/fb_authentication.dart';
import '../authentication/login_and_signup_screen.dart';
import 'new_article_screen.dart';

class HomeScreenDoctor extends StatefulWidget {
  const HomeScreenDoctor({Key? key}) : super(key: key);

  @override
  State<HomeScreenDoctor> createState() => _HomeScreenDoctorState();
}

class _HomeScreenDoctorState extends State<HomeScreenDoctor> {
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

    allArticles = await FbArticlesFunctions.getArticlesWithoutMe(context, currentUser!.email);
    allArticles.sort((a, b) {
      return b.updatedAt.compareTo(a.updatedAt);
    });

    await Future.delayed(const Duration(seconds: 1));
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
      body: Column(
        children: [
          Expanded(
            child: !isGettingData && allArticles.isEmpty
                ? const Center(child: Text("No any articles yet"))
                // ? const Center(child: Text("لا يوجد مقالات"))
                : ListView.builder(
                    itemCount: isGettingData ? 5 : allArticles.length,
                    itemBuilder: (context, index) {
                      return isGettingData
                          ? AllShimmerLoaded.shimmerArticle(context)
                          : ShowArticleInPost(
                              article: allArticles[index],
                              currentUser: currentUser!,
                            );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          Navigator.pushNamed(context, NewArticleScreen.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade400)),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.add_circle,
                color: Colors.blue,
                size: 32,
              ),
              kSizeBoxW8,
              Text(
                "New Article",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
