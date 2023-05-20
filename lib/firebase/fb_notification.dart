import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class FbNotificationFunctions {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future<String?> getToken() async {
    return await firebaseMessaging.getToken();
  }

  static initializeNotification() {
    firebaseMessaging.getInitialMessage().then((RemoteMessage? remoteMessage) {
      log("message getInitialMessage: ${remoteMessage?.data}");
      print("message getInitialMessage: ${remoteMessage?.data}");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      log("message onMessage: ${remoteMessage?.data}");
      print("message onMessage: ${remoteMessage?.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      log("message onMessageOpenedApp: ${remoteMessage?.data}");
      print("message onMessageOpenedApp: ${remoteMessage?.data}");
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage? remoteMessage) async {
      log("message onBackgroundMessage: ${remoteMessage?.data}");
      print("message onBackgroundMessage: ${remoteMessage?.data}");
    });
  }

  /////////////////////

  static Future<AccessToken> getAccessToken() async {
    final serviceAccount = await rootBundle.loadString("assets/msa-palliative-care-firebase-adminsdk-1mxsc-f7314c47ce.json");
    final data = await json.decode(serviceAccount);

    final accountCredentials = ServiceAccountCredentials.fromJson(
        {
          "private_key_id": data['private_key_id'],
          "private_key": data['private_key'],
          "client_email": data['client_email'],
          "client_id": data['client_id'],
          "type": data['type'],
        }
    );

    final scopes = ["https://www.googleapis.com/auth/firebase.messaging"];
    final AuthClient authClient = await clientViaServiceAccount(accountCredentials, scopes)..close();

    print(authClient.credentials.accessToken);
    return authClient.credentials.accessToken;
  }

  //////////////

  static Future<void> sendNotificationMessage(String userToken, String senderName, String message) async {
    try {
      String? myToken;
      await FbNotificationFunctions.getAccessToken().then((value) => myToken = value.data);

      Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/msa-palliative-care/messages:send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myToken',
        },
        body: jsonEncode({
          "message": {
            "token": userToken,
            "notification": {
              // "title": "لديك رسالة جديدة من $senderName",
              "title": "You have a new message from $senderName",
              "body": message
            },
            // "data": {"senderName": senderName, "isDoctor": isDoctor}
          }
        }),
      );
    } catch (error) {
      log("Error is: ${error.toString()}");
    }
  }

  //////////////

  static Future<void> sendNotificationArticle(String topicId, String notificationTitle, String notificationBody) async {
    try {
      String? myToken;
      await FbNotificationFunctions.getAccessToken().then((value) => myToken = value.data);

      Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/msa-palliative-care/messages:send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myToken',
        },
        body: jsonEncode({
          "message": {
            "topic": topicId,
            "notification": {
              // "title": "New articles in topic ($topicTitle)",
              "title": notificationTitle,
              // "body": "$doctorName published a new article titled ($articleTitle)",
              "body": notificationBody
            }
          }
        }),
      );
    } catch (error) {
      log("Error is: ${error.toString()}");
    }
  }

  //////////////

  static Future<void> sendNotificationUpdatedTopic(String topicId, String topicTitle, String doctorName) async {
    try {
      String? myToken;
      await FbNotificationFunctions.getAccessToken().then((value) => myToken = value.data);

      Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/msa-palliative-care/messages:send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myToken',
        },
        body: jsonEncode({
          "message": {
            "topic": topicId,
            "notification": {
              "title": "$doctorName modified a topic that you subscribed to.",
              "body": "The topic is named ${topicTitle}"
            }
          }
        }),
      );
    } catch (error) {
      log("Error is: ${error.toString()}");
    }
  }

  //////////////

  static Future<void> sendNotificationComments(String articleId, String doctorCreateArticleName,
      String commentUserName, String comment) async {
    try {
      String? myToken;
      await FbNotificationFunctions.getAccessToken().then((value) => myToken = value.data);

      Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/msa-palliative-care/messages:send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myToken',
        },
        body: jsonEncode({
          "message": {
            "topic": articleId,
            "notification": {
              "title":
                  "$commentUserName commented on the article of Dr.$doctorCreateArticleName",
              "body": comment
            }
          }
        }),
      );
    } catch (error) {
      log("Error is: ${error.toString()}");
    }
  }
}
