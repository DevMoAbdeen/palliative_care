import 'package:flutter/material.dart';

typedef ConvertDateFunction = String Function(String date);

const Color kMainColorDark = Color(0xFF003AFC);
const Color kMainColorLight = Color(0xFF6589FF);
const Color kBackgroundColor = Color(0xFFF7F6FF);

const String subscribedTopicChannel = "subscribed_topic_channel";
const String sendMessageChannel = "send_message_channel";

const Widget kSizeBoxEmpty = SizedBox();
const Widget kSizeBoxH8 = SizedBox(height: 8);
const Widget kSizeBoxW8 = SizedBox(width: 8);
const Widget kSizeBoxH16 = SizedBox(height: 16);
const Widget kSizeBoxW16 = SizedBox(width: 16);
const Widget kSizeBoxH24 = SizedBox(height: 24);
const Widget kSizeBoxH32 = SizedBox(height: 32);

const kTextFieldDecoration = InputDecoration(
  hintText: 'any text',
  hintTextDirection: TextDirection.ltr,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: UnderlineInputBorder(),
  prefixIconColor: kMainColorLight,
  suffixIconColor: kMainColorLight,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kMainColorLight, width: 2.0),
  ),
);

const kDivider = Divider(
  indent: 0,
  color: Colors.grey,
  thickness: .5,
  endIndent: 0,
);

enum UserRole {Admin, Doctor, Patient}
enum ActivityType {Likes, Comments, Others}


