import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/statemanagment/provider_user.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

class FbAuthentication {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static dynamic loginWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> updatePassword(String newPassword) async {
    return await _auth.currentUser!.updatePassword(newPassword);
  }

  static dynamic signUpWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /////////////////////

  static String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  static logoutUser() {
    _auth.signOut();
  }

  /////////////////

  static Future<UserModel?> getUserData(BuildContext context, String email) async {
    UserModel? userModel;
    try {
      DocumentSnapshot snapshot = await _db.collection('Users').doc(email).get();

      if (snapshot.get("role").toString().isNotEmpty) {
        userModel = UserModel.fromFirebase(snapshot as DocumentSnapshot<Map<String, dynamic>>);
        if (userModel.role == UserRole.Doctor.name) {
          DoctorModel doctorModel = DoctorModel.fromFirebase(snapshot);
          Provider.of<UserProvider>(context, listen: false).setDataCurrentDoctor(doctorModel);
        }
        Provider.of<UserProvider>(context, listen: false).setDataCurrentUser(userModel);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'),));
      log(e.toString());
    }
    return userModel;
  }

  //////////////////////

  static Future<UserModel?> getPatientData(BuildContext context, String email) async {
    UserModel? userModel;
    try {
      DocumentSnapshot snapshot = await _db.collection('Users').doc(email).get();
      userModel = UserModel.fromFirebase(snapshot as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
    return userModel;
  }

  //////////////////////

  static Future<DoctorModel?> getDoctorData(BuildContext context, String email) async {
    DoctorModel? doctor;
    try {
      DocumentSnapshot snapshot = await _db.collection('Users').doc(email).get();
      log("snapshot: ${snapshot.data()}");
      doctor = DoctorModel.fromFirebase(snapshot as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
    return doctor;
  }

  //////////////////////

  static Future<bool> addNewDoctor(BuildContext context, DoctorModel doctor) async {
    try {
      await _db.collection("Users").doc(doctor.email).set(doctor.toFirebase());
      return true;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
      return false;
    }
  }

  //////////////////////

  static Future<bool> addNewPatient(BuildContext context, UserModel user) async {
    try {
      await _db.collection("Users").doc(user.email).set(user.toFirebase());
      Provider.of<UserProvider>(context, listen: false).setDataCurrentUser(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged in by: ${user.email}')));
      return true;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
      return false;
    }
  }

  ///////////////

  static Future<void> updateUserData(BuildContext context, String name, String email, String address,
      String mobile, String birthdate, String? imageUrl, String? specialty) async {
    try {
      await _db.collection("Users").doc(email).update({
        "name": name,
        "address": address,
        "mobile": mobile,
        "birthdate": birthdate,
        "imageUrl": imageUrl,
        if (specialty != null) ...{
          "specialty": specialty
        },
      });

      var snackBar = const SnackBar(content: Text('Your data has been updated'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error update, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///////////////

  static Future<void> updateUserToken(BuildContext context, String email, String newToken) async {
    try {
      await _db.collection("Users").doc(email).update(
          {
            "token": newToken
          }
      );
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error update token, please logout and login again'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  //////////////////////////

  static Future<bool> handleSubscribedTopic(BuildContext context, String myEmail, String topicId, bool isAdded) async {
    try {
      await _db.collection("Users").doc(myEmail).update(
          {
            "subscribedTopics": isAdded
                ? FieldValue.arrayUnion([topicId])
                : FieldValue.arrayRemove([topicId])
          }
      );
      isAdded
          ? await FirebaseMessaging.instance.subscribeToTopic(topicId)
          : await FirebaseMessaging.instance.unsubscribeFromTopic(topicId);

      return true;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error handle subscribed topic, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

  ////////////////////////////

  static Future<bool> deleteUser(BuildContext context, String userEmail) async {
    try {
      await _db.collection("Users").doc(userEmail).delete();
      return true;
    } catch (error) {
      var snackBar = SnackBar(content: Text('Error delete, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }
}
