import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/models/topic.dart';

class FbTopicsFunctions {
  static final _db = FirebaseFirestore.instance;

  static Future<List<Topic>> getAllTopics(BuildContext context) async {
    List<Topic> allTopics = [];
    try {
      await _db.collection("Topics").orderBy("updatedAt", descending: true).get().then((querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            Topic category = Topic.fromFirebase(docSnapshot);
            allTopics.add(category);
            print('${docSnapshot.id} => ${docSnapshot.data()}');
          }
        }
      );
    } catch (e) {
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return allTopics;
  }

  //////////

  static Future<List<Topic>> getMyTopics(BuildContext context, String myEmail) async {
    List<Topic> myTopics = [];
    try {
      await _db.collection("Topics")
          .where("doctorEmailCreated", isEqualTo: myEmail)
          .orderBy("createdAt", descending: true)
          .get()
          .then(
        (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            Topic topic = Topic.fromFirebase(docSnapshot);
            myTopics.add(topic);
            print('${docSnapshot.id} => ${docSnapshot.data()}');
          }
        }
      );
    } catch (e) {
      log(e.toString());
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return myTopics;
  }

  //////////

  static Future<Topic?> createNewTopic(BuildContext context, Topic topic) async {
    try {
      String id = "";
      await _db.collection("Topics")
          .add(topic.toFirebase())
          .then((documentSnapshot) => id = documentSnapshot.id);

      Topic newTopic = Topic(
          topicId: id,
          title: topic.title,
          description: topic.description,
          doctorEmailCreated: topic.doctorEmailCreated,
          createdAt: topic.createdAt,
          updatedAt: topic.updatedAt);

      var snackBar = SnackBar(
        content: Text(
          "Topic (${newTopic.title}) has been created",
          style: TextStyle(color: Colors.white),
        ),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.blue,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return newTopic;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error add topic, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
  }

  // //////////
  //
  // static Future<bool> handleSubscribedUsers(BuildContext context, String topicId, String myEmail, bool isAdded) async{
  //   try{
  //     await _db.collection("Topics").doc(topicId).update({
  //       "subscribedUsers": isAdded
  //           ? FieldValue.arrayUnion([myEmail])
  //           : FieldValue.arrayRemove([myEmail])
  //     });
  //     isAdded
  //         ? await FirebaseMessaging.instance.subscribeToTopic(topicId)
  //         : await FirebaseMessaging.instance.unsubscribeFromTopic(topicId);
  //
  //     return true;
  //   }catch(error){
  //     var snackBar = SnackBar(content: Text('Error handle subscribed users, ${error.toString()}'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     return false;
  //   }
  // }
  //
  //////////

  static Future<bool> updateTopic(BuildContext context, String topicId,
      String newTopicName, String newDescription, String date) async {
    try {
      await _db.collection("Topics").doc(topicId).update({
        "title": newTopicName,
        "description": newDescription,
        "updatedAt": date
      });
      var snackBar = const SnackBar(content: Text('Topic has been updated'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return true;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error update, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  //////////

  static Future<bool> deleteTopic(BuildContext context, String topicId) async {
    try {
      await _db.collection("Topics").doc(topicId).delete();
      var snackBar = const SnackBar(content: Text('Topic has been deleted'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return true;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }
}
