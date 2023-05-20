import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/models/article.dart';
import 'fb_comments.dart';

class FbArticlesFunctions {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> createNewArticle(BuildContext context, Article article) async {
    try {
      String id = "";
      await _db.collection("Articles").add(article.toFirebase()).then((documentSnapshot) async {
        id = documentSnapshot.id;
        await FbCommentsFunctions.createCommentsArticle(context, id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Article has been added successfully',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ));

      return true;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error add article, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  ////////////////

  static Future<bool> updateArticle(BuildContext context, Article updatedArticle) async {
    try {
      await _db.collection("Articles").doc(updatedArticle.articleId).update(
        {
          "title": updatedArticle.title,
          "description": updatedArticle.description,
          "images": updatedArticle.images,
          "videos": updatedArticle.videos,
          "updatedAt": updatedArticle.updatedAt,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Article has been updated successfully',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ));

      return true;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error update article, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  ////////////////

  static Future<List<Article>> getAllArticles(BuildContext context) async {
    List<Article> allArticles = [];
    try {
      await _db
          .collection("Articles")
          .where("hidden", isEqualTo: false)
          .orderBy("updatedAt", descending: true)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Article articles = Article.fromFirebase(docSnapshot);
          allArticles.add(articles);
        }
      });
    } catch (e) {
      log("Error fetch data, ${e.toString()}");
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return allArticles;
  }

  //////////////////////////

  static Future<List<Article>> getArticlesWithoutMe(BuildContext context, String myEmail) async {
    List<Article> allArticles = [];
    try {
      await _db
          .collection("Articles")
          .where(Filter.and(
            Filter("doctor.email", isNotEqualTo: myEmail),
            Filter("hidden", isEqualTo: false),
          ))
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Article articles = Article.fromFirebase(docSnapshot);
          allArticles.add(articles);
        }
      });
    } catch (e) {
      log("Error fetch data, ${e.toString()}");
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return allArticles;
  }

  //////////////////////////

  static Future<Article?> getOneArticle(BuildContext context, String articleId) async {
    Article? article;
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('Articles').doc(articleId).get();
      if (snapshot.data() != null) {
        article = Article.fromFirebase(snapshot);
      }
    } catch (e) {
      log("Error get article, ${e.toString()}");
      var snackBar = SnackBar(content: Text('Error get article, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return article;
  }

  //////////////////////////

  static Future<List<Article>> getDoctorsArticles(BuildContext context, String email) async {
    List<Article> myArticles = [];
    try {
      await _db.collection("Articles")
          .where(Filter.and(
            Filter("doctor.email", isEqualTo: email),
            Filter("hidden", isEqualTo: false),
          ))
          .orderBy("createdAt", descending: true)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Article article = Article.fromFirebase(docSnapshot);
          myArticles.add(article);
        }
      });
    } catch (e) {
      log(e.toString());
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return myArticles;
  }

  //////////////////////////

  static Future<List<Article>> getMyHiddenArticle(BuildContext context, String myEmail) async {
    List<Article> myArticles = [];
    try {
      await _db.collection("Articles")
          .where(Filter.and(
            Filter("doctor.email", isEqualTo: myEmail),
            Filter("hidden", isEqualTo: true),
          ))
          .orderBy("updatedAt", descending: true)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Article article = Article.fromFirebase(docSnapshot);
          myArticles.add(article);
        }
      });
    } catch (e) {
      log(e.toString());
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return myArticles;
  }

  //////////////////////////

  static Future<List<Article>> getArticlesTopic(BuildContext context, String topicId) async {
    List<Article> myArticles = [];
    try {
      await _db.collection("Articles")
          .where(Filter.and(
            Filter("topic.id", isEqualTo: topicId),
            Filter("hidden", isEqualTo: false),
          ))
          .orderBy("updatedAt", descending: true)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Article article = Article.fromFirebase(docSnapshot);
          myArticles.add(article);
        }
      });
    } catch (e) {
      log(e.toString());
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return myArticles;
  }

  //////////

  static Future<void> handleLikesArticle(BuildContext context, String articleId, List<dynamic> likes, String date) async {
    try {
      await _db.collection("Articles").doc(articleId).update({"likes": likes, "updatedAt": date});
    } catch (error) {
      log(error.toString());
      var snackBar = SnackBar(content: Text('Error handle like, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ////////////////////////

  static Future<void> handleUpdateArticle(BuildContext context, String articleId, String date) async {
    try {
      await _db
          .collection("Articles")
          .doc(articleId)
          .update({"updatedAt": date});
    } catch (error) {
      log(error.toString());
      var snackBar = SnackBar(content: Text('Error handle like, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ////////////////////////

  static Future<void> updateDoctorDataInArticles(BuildContext context, String doctorEmail, String doctorName,
      String? doctorImage, String doctorSpecialty) async {
    try {
      List<Article> doctorArticles = await getDoctorsArticles(context, doctorEmail);
      doctorArticles.addAll(await getMyHiddenArticle(context, doctorEmail));
      doctorArticles.forEach((element) async {
        await _db.collection("Articles").doc(element.articleId).update({
          if (element.doctor.name != doctorName) ...{
            "doctor.name": doctorName
          },
          if (element.doctor.imageUrl != doctorImage) ...{
            "doctor.imageUrl": doctorImage,
          },
          if (element.doctor.specialty != doctorSpecialty) ...{
            "doctor.specialty": doctorSpecialty,
          },
        });
      });
    } catch (error) {
      log(error.toString());
      var snackBar = SnackBar(content: Text('Error handle like, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ////////////////////////

  static Future<bool> deleteArticle(BuildContext context, String articleId) async {
    try {
      await _db.collection("Articles").doc(articleId).delete();
      var snackBar = const SnackBar(content: Text('Article has been deleted'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      FbCommentsFunctions.deleteCommentsArticle(context, articleId);
      return true;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  ////////////////////////

  static Future<bool> hideArticle(BuildContext context, String articleId, String date) async {
    try {
      await _db
          .collection("Articles")
          .doc(articleId)
          .update({"hidden": true, "updatedAt": date});
      var snackBar = SnackBar(content: Text('No one else will be able to see this article'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return true;
    } catch (error) {
      log(error.toString());
      var snackBar = SnackBar(content: Text('Error hide article, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  ////////////////////////

  static Future<bool> unHideArticle(BuildContext context, String articleId, String date) async {
    try {
      await _db
          .collection("Articles")
          .doc(articleId)
          .update({"hidden": false, "updatedAt": date});
      var snackBar = SnackBar(content: Text('Everyone will be able to see the article anymore'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return true;
    } catch (error) {
      log(error.toString());
      var snackBar = SnackBar(content: Text('Error hide article, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  ////////////////////////

  static Future<void> deleteDoctorArticles(BuildContext context, String doctorEmail) async {
    try {
      List<Article> doctorArticles = await getDoctorsArticles(context, doctorEmail);
      doctorArticles.addAll(await getMyHiddenArticle(context, doctorEmail));

      doctorArticles.forEach((element) async {
        await deleteArticle(context, element.articleId!);
      });
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
