import 'package:flutter/material.dart';
import 'package:palliative_care/screens/authentication/login_and_signup_screen.dart';
import 'package:palliative_care/statemanagment/provider_topics.dart';
import 'package:palliative_care/statemanagment/provider_user.dart';
import 'package:provider/provider.dart';
import 'components/display_files.dart';
import 'firebase/fb_authentication.dart';
import 'dart:io';

class AllFunctions{

  static String convertDate(String date){
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(5, 7));
    int day = int.parse(date.substring(8, 10));
    int hour = int.parse(date.substring(11, 13));
    int minute = int.parse(date.substring(14, 16));

    final createdArticle = DateTime(year, month, day, hour, minute);
    final dateNow = DateTime.now();
    int differenceMinutes = dateNow.difference(createdArticle).inMinutes;

    if(differenceMinutes < 1){
      return "Just now";
    }else if(differenceMinutes <= 60){
      return "$differenceMinutes minutes ago";
    }else{
      int differenceHours = dateNow.difference(createdArticle).inHours;
      if(differenceHours < 24){
        return "$differenceHours hours ago";
      }else if (differenceHours >= 24 && differenceHours <= 48){
        String hourSend = hour > 12 ? "${hour - 12}:$minute PM" : hour == 0 ? "12:$minute AM" : "$hour:$minute AM";
        return "Yesterday, $hourSend";
      }else{
        int differenceDays = dateNow.difference(createdArticle).inDays;
        if(differenceDays < 10) {
          return "$differenceDays days ago";
        }else {
          String hourSend = hour > 12 ? "${hour - 12}:$minute PM" : hour == 0 ? "12:$minute AM" : "$hour:$minute AM";
          return "$year/$month/$day - $hourSend";
        }
      }
    }
  }

  ///////////

  static String convertDateToMessage(String date){
    // DateFormat("YYYY-MM-DD HH:MM:SS.668735")
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(5, 7));
    int day = int.parse(date.substring(8, 10));
    int hour = int.parse(date.substring(11, 13));
    int minute = int.parse(date.substring(14, 16));

    final createdArticle = DateTime(year, month, day, hour, minute);
    final dateNow = DateTime.now();
    int differenceDays = dateNow.difference(createdArticle).inDays;

    if(differenceDays == 0 || differenceDays == 1){
      String hourSend = hour > 12 ? "${hour - 12}:$minute PM" : hour == 0 ? "12:$minute AM" : "$hour:$minute AM";
      return differenceDays == 0 ? hourSend : "Yesterday, $hourSend";
    }else {
      String hourSend = hour > 12 ? "${hour - 12}:$minute PM" : hour == 0 ? "12:$minute AM" : "$hour:$minute AM";
      return "$year/$month/$day - $hourSend";
    }
  }

  ///////////

  static PopupMenuEntry<int> createPopupMenuItem(
      int value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.black),
        ],
      ),
    );
  }

  /////////////////////

  static String getFirstLetter(String name) {
    if(name.startsWith("Dr.")){
      name.replaceFirst("Dr.", "");
    }
    List<String> names = name.split(" ");
    return names[0][0].toUpperCase() + names[1][0].toUpperCase();
  }

  /////////////////////

  static Widget showDialogLogout(BuildContext context){
    return AlertDialog(
      title: const Text('Logout!'),
      content: const Text('Are you sure you want logout ?'),
      icon: const Icon(Icons.logout),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: InkWell(child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),),
              ),
            ),
            InkWell(
              onTap: () async {
                Provider.of<UserProvider>(context, listen: false).resetData();
                Provider.of<TopicsProvider>(context, listen: false).resetAllData();
                await FbAuthentication.logoutUser();
                // Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
                Navigator.pushNamedAndRemoveUntil(context, LoginAndSignupScreen.id, (route) => false);
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: InkWell(child: Text("Yes", style: TextStyle(fontWeight: FontWeight.bold)),),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /////////////////////

  static Widget showDialogDelete(BuildContext context, {required String deleteWhat, required Function deleteFunction}){
    return AlertDialog(
      title: const Text('Delete !'),
      content: Text('Are you sure you want delete this $deleteWhat ?'),
      icon: const Icon(Icons.delete_forever),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            InkWell(
              onTap: () {
                deleteFunction();
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Yes", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///////////////////////////////////

  static Widget showDialogSendFile(BuildContext context, {required String fileType, required String filePath, required Function sendFile}){
    return AlertDialog(
      title: const Text('Send'),
      content: Text('Are you want send this $fileType ?'),
      icon: Icon(fileType == "image" ? Icons.image : Icons.slow_motion_video_rounded),
      actions: [
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: fileType == "image" ? Image.file(
                File(filePath),
              ) : ShowVideoScreen(videoUrl: null, videoPath: filePath),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    sendFile();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Yes", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  ///////////////////////////////////



}