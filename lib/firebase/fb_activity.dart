import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/models/article.dart';
import '../constants.dart';

class FbActivitiesFunctions {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createUserActivity(BuildContext context, String myEmail) async {
    List<Map> likes = [];
    List<Map> comments = [];
    List<Map> others = [];

    try{
      await _db.collection("Activities").doc(myEmail).set(
          {
            ActivityType.Likes.name: likes,
            ActivityType.Comments.name: comments,
            ActivityType.Others.name: others,
          }
      );
    }catch (error){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}'),),
      );
    }
  }

  /////////////////////

  static handleLikeActivity(BuildContext context, bool isPutLike, String myEmail, String date, Article article) async {
    try {
      await _db.collection('Activities').doc(myEmail).update({
        ActivityType.Likes.name: FieldValue.arrayUnion([
          {
            'articleId': article.articleId,
            'description': isPutLike
                ? "You liked an article by ${article.doctor.name} entitled (${article.title})"
                : "You deleted your like for ${article.doctor.name} article entitled (${article.title})",
            'date': date,
          }
        ])
      });
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error handle like, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /////////////////////

  static handleCommentActivity(BuildContext context, String myEmail, String date, Article article, [String? comment]) async {
    try {
      await _db.collection('Activities').doc(myEmail).update({
        ActivityType.Comments.name: FieldValue.arrayUnion([
          {
            'articleId': article.articleId,
            'description': comment != null
                ? "You commented on ${article.doctor.name} article, ($comment)"
                : "You deleted your comment on ${article.doctor.name} article",
            'date': date,
          }
        ])
      });
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error handle comment, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /////////////////////

  static handleArticleActivity(BuildContext context, String myEmail, String articleTitle, String date, bool isCreate) async {
    try {
      await _db.collection('Activities').doc(myEmail).update({
        ActivityType.Others.name: FieldValue.arrayUnion([
          {
            'description': isCreate
                ? "You created an article titled ($articleTitle)"
                : "You deleted your article which titled ($articleTitle)",
            'date': date,
          }
        ])
      });
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error handle article activity, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /////////////////////

  static handleTopicActivity(BuildContext context, String myEmail, String topicTitle, String date, bool isCreate) async {
    try {
      await _db.collection('Activities').doc(myEmail).update({
        ActivityType.Others.name: FieldValue.arrayUnion([
          {
            'description': isCreate
                ? "You created an topic titled ($topicTitle)"
                : "You deleted your topic which titled ($topicTitle)",
            'date': date,
          }
        ])
      });
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error handle topic activity, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /////////////////////

  static handleSubscribedTopicActivity(BuildContext context, String myEmail, String topicTitle, String date, bool isSubscribe) async {
    try {
      await _db.collection('Activities').doc(myEmail).update({
        ActivityType.Others.name: FieldValue.arrayUnion([
          {
            'description': isSubscribe
                ? "You subscribe an topic titled ($topicTitle)"
                : "You unsubscribe a topic which titled ($topicTitle)",
            'date': date,
          }
        ])
      });
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error handle subscribe topic activity, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

////////////////////////////////////////////
///////////////////////////////////////////

  static Future<Map<String, dynamic>> getUserActivities(BuildContext context, String email) async {
    Map<String, dynamic> allActivities = {};

    try {
      DocumentSnapshot snapshot = await _db.collection("Activities").doc(email).get();
      allActivities = snapshot.data() as Map<String, dynamic>;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      log(error.toString());
    }
    return allActivities;
  }

  //////////////////////////

  static Future<void> deleteUserActivity(BuildContext context, String userEmail) async {
    try {
      await _db.collection('Activities').doc(userEmail).delete();
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete user activities, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
