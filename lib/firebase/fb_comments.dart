import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/models/comment.dart';

class FbCommentsFunctions {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createCommentsArticle(BuildContext context, String articleId) async {
    List<Map> comments = [];

    try{
      await _db.collection("Comments").doc(articleId).set({"comments": comments,});
    }catch(error){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
        ),
      );
    }
  }

  /////////////////////////

  static Future<void> addComment(BuildContext context, String articleId, Comment comment) async {
    try {
      await _db.collection('Comments').doc(articleId).update(
          {
            "comments": FieldValue.arrayUnion([comment.toFirebase()])
          }
      );
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error add comment, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///////////////////////////

  static Future<void> deleteComment(BuildContext context, String articleId, Comment comment) async {
    try {
      await _db.collection('Comments').doc(articleId).update(
          {
            "comments": FieldValue.arrayRemove([comment.toFirebase()])
          }
      );
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete comment, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///////////////////////////

  static Future<List<Comment>> getCommentsOfArticle(BuildContext context, String articleId) async {
    List<Comment> comments = [];
    try {
      await _db.collection('Comments').doc(articleId).get().then((value) {
        if (value.data() != null) {
          for (var com in value.data()!["comments"]) {
            Comment comment = Comment.fromFirebase(com);
            comments.add(comment);
          }
        }
      });
    } catch (e) {
      log(e.toString());
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return comments;
  }

  ///////////////////////////

  static Future<void> updateComment(BuildContext context, String articleId,
      List<Comment> allComments, String updatedComment, int index) async {
    try {
      allComments[index].comment = updatedComment;
      List<Map> comments = allComments.map((element) => element.toFirebase()).toList();

      await _db
          .collection('Comments')
          .doc(articleId)
          .update({"comments": comments});
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete comment, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///////////////////////////

  static Future<void> updateUserDataInComments(BuildContext context, String userEmail, String name, String? imageUrl) async {
    List<Map> comments = [];
    try {
      await _db.collection('Comments').get().then((value) async {
        if (value.docs.isNotEmpty) {
          for (var commentDoc in value.docs) {
            comments.clear();
            var com = commentDoc.data()["comments"];
            for (int i = 0; i < com.length; i++) {
              Comment comment = Comment.fromFirebase(com[i]);
              if (comment.email == userEmail) {
                comment.name = name;
                comment.imageUrl = imageUrl;
              }
              comments.add(comment.toFirebase());
            }

            await _db
                .collection('Comments')
                .doc(commentDoc.id)
                .update({"comments": comments});
          }
        }
      });
    } catch (e) {
      log(e.toString());
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  //////////////////////////

  static Future<void> deleteCommentsArticle(BuildContext context, String articleId) async {
    try {
      await _db.collection('Comments').doc(articleId).delete();
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete comments, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

///////////////////////////

  static Future<void> deleteUserComments(BuildContext context, String userEmail) async {
    try {
      await _db.collection('Comments').get().then((value) async {
        if (value.docs.isNotEmpty) {
          for (var commentDoc in value.docs) {
            var com = commentDoc.data()["comments"] as List;
            for (int i = 0; i < com.length; i++) {
              Comment comment = Comment.fromFirebase(com[i]);
              if (comment.email == userEmail) {
                await _db.collection('Comments').doc(commentDoc.id).delete();
              }
            }
          }
        }
      });
    } catch (e) {
      log(e.toString());
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
