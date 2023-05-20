import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palliative_care/firebase/fb_files.dart';
import 'package:palliative_care/models/message.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/screens/authentication/login_and_signup_screen.dart';
import 'package:palliative_care/screens/doctor/doctor_profile_screen.dart';
import 'package:palliative_care/screens/patient/patient_profile_screen.dart';
import 'package:provider/provider.dart';
import '../../components/display_files.dart';
import '../../constants.dart';
import '../../firebase/fb_chat.dart';
import '../../firebase/fb_notification.dart';
import '../../functions.dart';
import '../../statemanagment/provider_user.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserEmail;
  final String otherUserName;
  final String? otherUserImage;
  final String otherUserRole;
  final String otherUserToken;

  const ChatScreen({super.key,
    required this.otherUserEmail,
    required this.otherUserName,
    required this.otherUserImage,
    required this.otherUserRole,
    required this.otherUserToken,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  UserModel? currentUser;
  TextEditingController textSendController = TextEditingController();

  void getCurrentUser() {
    currentUser = Provider.of<UserProvider>(context, listen: false).getCurrentUser;
    if (currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, LoginAndSignupScreen.id, (route) => false);
    }
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    textSendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        leading: Row(
          children: [
            kSizeBoxW8,
            IconButton(
              icon: const Icon(Icons.keyboard_backspace_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: InkWell(
          onTap: () {
            widget.otherUserRole == UserRole.Doctor.name
                ? Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    DoctorProfileScreen(doctorEmail: widget.otherUserEmail, isFromPageView: false),
                  ))
                : widget.otherUserRole == UserRole.Patient.name
                    ? Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        PatientProfileScreen(email: widget.otherUserEmail, isFromPageView: false),
                      ))
                    : null;
          },
          child: Row(
            children: [
              widget.otherUserImage != null
                  ? Hero(
                      tag: widget.otherUserImage!,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade400,
                        backgroundImage: NetworkImage(widget.otherUserImage!),
                      ),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: kMainColorLight,
                      child: Center(
                        child: Text(
                          AllFunctions.getFirstLetter(widget.otherUserName),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              kSizeBoxW8,
              Text(
                widget.otherUserName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: FbChat.getChatMessages(context, currentUser!.email, widget.otherUserEmail),
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  List<dynamic> messages = snapShot.data!.docs.reversed.toList();

                  return Expanded(
                    child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        Message message = Message.fromFirebase(messages[index]);
                        return MessageBubble(
                          message: message,
                          isMe: message.senderEmail == currentUser!.email,
                        );
                      },
                    ),
                  );
                } else {
                  return const Expanded(
                    child: Center(
                      child: Text('Wait to get data...'),
                    ),
                  );
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textSendController,
                      decoration: kMessageTextFieldDecoration,
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (v) {
                        setState(() {});
                      },
                    ),
                  ),
                  textSendController.text.isNotEmpty
                      ? kSizeBoxEmpty
                      : IconButton(
                          onPressed: () async {
                            ImagePicker imagePicker = ImagePicker();
                            XFile? file = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                            if (file != null) {
                              String imageName = DateTime.now().millisecondsSinceEpoch.toString();
                              if (mounted) {
                                showDialog(context: context, builder: (context) {
                                  return AllFunctions.showDialogSendFile(
                                    context, fileType: "image", filePath: file.path,
                                    sendFile: () async {
                                      String imageDownloadUrl = await FbFiles.uploadImage(context, file, imageName);
                                      Message message = Message(message: null, imageUrl: imageDownloadUrl,
                                        videoUrl: null, senderEmail: currentUser!.email, receiverEmail: widget.otherUserEmail,
                                        date: DateTime.now().toLocal().toString(),
                                      );
                                      await FbChat.sendMessage(context, message);
                                      FbNotificationFunctions.sendNotificationMessage(widget.otherUserToken, currentUser!.name, "صورة جديدة, افتح المحادثة لرؤيتها");
                                    },
                                  );
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.image),
                        ),
                  textSendController.text.isNotEmpty
                      ? kSizeBoxEmpty
                      : IconButton(
                          onPressed: () async {
                            ImagePicker imagePicker = ImagePicker();
                            XFile? file = await imagePicker.pickVideo(source: ImageSource.gallery);
                            if (file != null) {
                              String videoName = DateTime.now().millisecondsSinceEpoch.toString();
                              if (mounted) {
                                showDialog(context: context, builder: (context) {
                                  return AllFunctions.showDialogSendFile(
                                    context, fileType: "video", filePath: file.path,
                                    sendFile: () async {
                                      String videoDownloadUrl = await FbFiles.uploadImage(context, file, videoName);
                                      Message message = Message(
                                        message: null, imageUrl: null, videoUrl: videoDownloadUrl,
                                        senderEmail: currentUser!.email, receiverEmail: widget.otherUserEmail,
                                        date: DateTime.now().toLocal().toString(),
                                      );
                                      await FbChat.sendMessage(context, message);
                                      FbNotificationFunctions.sendNotificationMessage(widget.otherUserToken, currentUser!.name, "فيديو جديد, افتح المحادثة لمشاهدته");
                                    },
                                  );
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.slow_motion_video_rounded),
                        ),
                  IconButton(
                    onPressed: () async {
                      String msg = textSendController.text.toString().trim();
                      if (msg.isNotEmpty) {
                        Message message = Message(message: msg, imageUrl: null, videoUrl: null,
                          senderEmail: currentUser!.email, receiverEmail: widget.otherUserEmail,
                          date: DateTime.now().toLocal().toString(),
                        );
                        FbChat.sendMessage(context, message);
                        FbNotificationFunctions.sendNotificationMessage(widget.otherUserToken, currentUser!.name, msg);
                        setState(() {
                          textSendController.clear();
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: kMainColorDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({Key? key, required this.message, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      margin: EdgeInsets.only(right: isMe ? 32 : 0, left: isMe ? 0 : 32),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Material(
            color: message.message == null
                ? null
                : isMe
                    ? Colors.blueAccent
                    : Colors.lightBlueAccent,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(8),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(16),
                  ),
            child: InkWell(
                onLongPress: () {
                  showDialog(context: context, builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Message!'),
                      content: isMe
                          ? const Text('Do you want delete this message..')
                          : const Text("Delete for me"),
                      icon: const Icon(Icons.delete),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await FbChat.deleteMessageForMe(message, isMe);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Just from me",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                isMe
                                    ? TextButton(
                                        onPressed: () async {
                                          await FbChat.deleteMessageForAll(message);
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "From all",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : kSizeBoxEmpty,
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
                },
                child: message.message != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.message!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              AllFunctions.convertDateToMessage(message.date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : message.imageUrl != null
                        ? InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                  ShowImageScreen(uri: message.imageUrl!, isWantDownload: true),
                              ));
                            },
                            child: Hero(
                              tag: message.imageUrl!,
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Image.network(
                                    message.imageUrl!,
                                    height: screenHeight / 4,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Container(
                                        color: Colors.white,
                                        width: screenWidth / 2,
                                        height: screenHeight / 4,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Image.asset("images/no_network.jpg", width: screenWidth / 2,);
                                    },
                                  ),
                                  Text(
                                    AllFunctions.convertDateToMessage(message.date),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                  ShowVideoScreen(videoUrl: message.videoUrl, videoPath: null),
                              ));
                            },
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Container(
                                    margin: const EdgeInsets.symmetric(vertical: 1),
                                    height: screenHeight / 4,
                                    width: screenWidth / 2,
                                    color: Colors.white,
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle,
                                        color: Colors.black,
                                        size: screenHeight / 10,
                                      ),
                                    ),
                                ),
                                Text(
                                  AllFunctions.convertDateToMessage(message.date),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
            ),
          ),
        ],
      ),
    );
  }
}
