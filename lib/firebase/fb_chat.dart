import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/models/message.dart';
import 'package:palliative_care/models/user.dart';

class FbChat {
  static final _db = FirebaseFirestore.instance;

  static Future<List<UserModel>> getAllUsers(BuildContext context) async {
    List<UserModel> allUsers = [];
    try {
      await _db
          .collection("Users")
          .where("role", isNotEqualTo: UserRole.Admin.name)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          UserModel user = UserModel.fromFirebase(docSnapshot);
          allUsers.add(user);
        }
      });
    } catch (e) {
      var snackBar = SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return allUsers;
  }

  ///////////////////////////

  static Future<void> sendMessage(BuildContext context, Message message) async {
    try {
      await _db
          .collection('Chat')
          .doc("${message.senderEmail}-${message.receiverEmail}")
          .collection("Messages")
          .doc(message.date)
          .set(message.toFirebase());

      await _db
          .collection('Chat')
          .doc("${message.receiverEmail}-${message.senderEmail}")
          .collection("Messages")
          .doc(message.date)
          .set(message.toFirebase());
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error send message, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///////////////////////////

  static Stream<QuerySnapshot<Map<String, dynamic>>>? getChatMessages(
      BuildContext context, String senderEmail, String receiverEmail) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> stream = _db
          .collection('Chat')
          .doc("$senderEmail-$receiverEmail")
          .collection("Messages")
          // .orderBy('date', descending: true)
          .snapshots();
      return stream;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  ///////////////////////////

  static Future<void> deleteMessageForMe(Message message, bool isMe) async {
    try {
      await _db
          .collection('Chat')
          .doc(isMe
              ? "${message.senderEmail}-${message.receiverEmail}"
              : "${message.receiverEmail}-${message.senderEmail}")
          .collection("Messages")
          .doc(message.date)
          .delete();
    } catch (e) {
      log(e.toString());
    }
  }

  ///////////////////////////

  static Future<void> deleteMessageForAll(Message message) async {
    try {
      await _db
          .collection('Chat')
          .doc("${message.senderEmail}-${message.receiverEmail}")
          .collection("Messages")
          .doc(message.date)
          .delete();

      await _db
          .collection('Chat')
          .doc("${message.receiverEmail}-${message.senderEmail}")
          .collection("Messages")
          .doc(message.date)
          .delete();
    } catch (e) {
      log(e.toString());
    }
  }

///////////////////////////

// static Future<void> deleteUserMessages(BuildContext context, String userEmail) async {
//   try {
//     await _db.collection("Chat").get().then((querySnapshot) {
//       for (var docSnapshot in querySnapshot.docs) {
//         log("message");
//       }
//
//     });
//
//   } catch (error) {
//     log("Error ${error.toString()}");
//     var snackBar = SnackBar(content: Text('Error delete message, ${error.toString()}'));
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }
}
