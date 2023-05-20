import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/models/article.dart';
import 'package:palliative_care/models/comment.dart';
import 'package:palliative_care/models/user.dart';
import 'package:palliative_care/screens/doctor/doctor_profile_screen.dart';
import 'package:palliative_care/screens/doctor/update_article_screen.dart';
import 'package:palliative_care/statemanagment/provider_user.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../firebase/fb_activity.dart';
import '../functions.dart';
import '../screens/patient/patient_profile_screen.dart';
import '../screens/joint/comments_bottom_sheet.dart';
import 'display_files.dart';

class MainBtn extends StatelessWidget {
  final String text;
  final bool showProgress;
  final Function() onPressed;

  const MainBtn({Key? key, required this.text, required this.showProgress, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        !showProgress ? onPressed() : null;
      },
      child: Container(
        height: 50.0,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              kMainColorLight,
              kMainColorDark,
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Center(
          child: showProgress
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}

/////////////////////////////

class MainWhiteContainer extends StatelessWidget {
  final Widget childWidget;

  const MainWhiteContainer({Key? key, required this.childWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: childWidget,
    );
  }
}

///////////////////////////

class ShowArticleInPost extends StatefulWidget {
  final Article article;
  final UserModel currentUser;
  final Function ?hideArticle;
  final Function? unHideArticle;
  final Function? deleteArticle;
  final Function? deleteArticleFromAdmin;

  const ShowArticleInPost({
    Key? key,
    required this.article,
    required this.currentUser,
    this.hideArticle,
    this.unHideArticle,
    this.deleteArticle,
    this.deleteArticleFromAdmin,
  }) : super(key: key);

  @override
  State<ShowArticleInPost> createState() => _ShowArticleInPostState();
}

class _ShowArticleInPostState extends State<ShowArticleInPost> {
  bool isClickDescription = false;

  void _openUpdateArticleScreen() async {
    Article? updatedArticle = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
        UpdateArticleScreen(oldArticle: widget.article,),
    ));

    if (updatedArticle != null) {
      widget.article.title = updatedArticle.title;
      widget.article.description = updatedArticle.description;
      widget.article.updatedAt = updatedArticle.updatedAt;
      widget.article.images = updatedArticle.images;
      widget.article.videos = updatedArticle.videos;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String? myEmail = Provider.of<UserProvider>(context, listen: false).getCurrentUser?.email;
    bool isLikedThisPost = widget.article.likes.contains("$myEmail");
    int numOfLikes = widget.article.likes.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: widget.article.doctor.imageUrl == null
                  ? CircleAvatar(
                      backgroundColor: kMainColorLight,
                      child: Text(
                        AllFunctions.getFirstLetter(widget.article.doctor.name),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : CircleAvatar(
                      backgroundImage:
                          NetworkImage(widget.article.doctor.imageUrl!),
                    ),
              title: Text(widget.article.doctor.name),
              subtitle: Text(widget.article.doctor.specialty),
              trailing: widget.currentUser.role == UserRole.Admin.name
                  ? IconButton(
                      onPressed: () {
                        if(widget.deleteArticleFromAdmin != null){
                          widget.deleteArticleFromAdmin!();
                        }
                      },
                      icon: const Icon(Icons.delete_forever),
                    )
                  : widget.currentUser.email == widget.article.doctor.email
                      ? PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            AllFunctions.createPopupMenuItem(1, "Update", Icons.update),
                            widget.article.hidden
                                ? AllFunctions.createPopupMenuItem(2, "Un Hide", Icons.visibility)
                                : AllFunctions.createPopupMenuItem(3, "Hide", Icons.visibility_off),
                            AllFunctions.createPopupMenuItem(4, "Delete", Icons.delete_forever),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 1:{
                                _openUpdateArticleScreen();
                              }
                              break;

                              case 2:{
                                if(widget.unHideArticle != null) {
                                  widget.unHideArticle!();
                                }
                              }
                              break;

                              case 3:{
                                if(widget.hideArticle != null) {
                                  widget.hideArticle!();
                                }
                              }
                              break;

                              case 4:{
                                if(widget.deleteArticle != null) {
                                  widget.deleteArticle!();
                                }
                              }
                              break;
                            }
                          },
                        )
                      : kSizeBoxEmpty,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    DoctorProfileScreen(doctorEmail: widget.article.doctor.email, isFromPageView: false)
                ));
              },
            ),
            kDivider,
            ConstrainedBox(
              constraints: const BoxConstraints(),
              child: SelectableText(
                widget.article.title,
                toolbarOptions: const ToolbarOptions(
                  copy: true,
                  selectAll: true,
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            kSizeBoxH8,
            widget.article.images.isEmpty && widget.article.videos.isEmpty
                ? kSizeBoxEmpty
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height / 3.5,
                          viewportFraction: 0.85,
                          enableInfiniteScroll: false,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 900),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.2,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: [
                          for (int i = 0; i < widget.article.images.length; i++) ...{
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                    ShowImageScreen(uri: widget.article.images[i], isWantDownload: true),
                                ));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                child: Hero(
                                  tag: widget.article.images[i],
                                  child: Image.network(
                                    widget.article.images[i],
                                    fit: BoxFit.fill,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Container(
                                        color: Colors.white,
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
                                      return Image.asset("images/no_network.jpg");
                                    },
                                  ),
                                ),
                              ),
                            )
                          },
                          for (int i = 0; i < widget.article.videos.length; i++) ...{
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                    ShowVideoScreen(videoUrl: widget.article.videos[i], videoPath: null),
                                ));
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 1),
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle,
                                      color: Colors.black,
                                      size: 100,
                                    ),
                                  ),
                              ),
                            )
                          }
                        ],
                      ),
                    ),
                  ),
            widget.article.images.isEmpty && widget.article.videos.isEmpty
                ? kSizeBoxEmpty
                : kSizeBoxH8,
            AnimatedSize(
              duration: widget.article.description.length > 3000
                  ? const Duration(milliseconds: 900)
                  : const Duration(milliseconds: 500),
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isClickDescription = !isClickDescription;
                      log("${widget.article.description.length}");
                    });
                  },
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: widget.article.description));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("The text has been copied"),
                      duration: Duration(seconds: 1),
                    ));
                  },
                  child: Text(
                    widget.article.description,
                    softWrap: false,
                    textDirection: TextDirection.ltr,
                    overflow: TextOverflow.ellipsis,
                    maxLines: isClickDescription ? 500 : 10,
                  ),
                ),
              ),
            ),
            kSizeBoxH8,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AllFunctions.convertDate(widget.article.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height:2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: Chip(
                    elevation: 5,
                    padding: const EdgeInsets.all(10),
                    backgroundColor: kBackgroundColor,
                    shadowColor: Colors.black,
                    avatar: Icon(
                      Icons.thumb_up,
                      size: 20,
                      color: isLikedThisPost ? kMainColorDark : Colors.black,
                    ),
                    label: Text(
                      '$numOfLikes | Likes',
                      style: TextStyle(
                        fontSize: 15,
                        color: isLikedThisPost ? kMainColorDark : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () {
                    String date = DateTime.now().toString();
                    setState(() {
                      if (isLikedThisPost) {
                        widget.article.likes.remove(myEmail);
                        FbActivitiesFunctions.handleLikeActivity(context, false, myEmail!, date, widget.article);
                      } else {
                        widget.article.likes.add(myEmail);
                        FbActivitiesFunctions.handleLikeActivity(context, true, myEmail!, date, widget.article);
                      }
                      List likes = widget.article.likes;
                      FbArticlesFunctions.handleLikesArticle(context, widget.article.articleId!, likes, date);
                    });
                  },
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      clipBehavior: Clip.hardEdge,
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setStateBottomSheet) {
                            return FractionallySizedBox(
                              heightFactor: 0.90,
                              child: BottomSheetComments(article: widget.article, currentUser: widget.currentUser),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Chip(
                    elevation: 5,
                    padding: EdgeInsets.all(10),
                    backgroundColor: kBackgroundColor,
                    shadowColor: Colors.black,
                    avatar: Icon(
                      Icons.comment,
                      size: 20,
                    ),
                    label: Text(
                      'Comments',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////

class ShowComment extends StatefulWidget {
  final Comment comment;
  final UserModel currentUser;
  final Function updateComment;
  final Function deleteComment;

  const ShowComment(
      {Key? key,
      required this.comment,
      required this.currentUser,
      required this.updateComment,
      required this.deleteComment})
      : super(key: key);

  @override
  State<ShowComment> createState() => _ShowCommentState();
}

class _ShowCommentState extends State<ShowComment> {
  bool isClickComment = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () async {
              if (widget.comment.role == UserRole.Patient.name) {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    PatientProfileScreen(email: widget.comment.email, isFromPageView: false)
                ));
              } else if (widget.comment.role == UserRole.Doctor.name) {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    DoctorProfileScreen(doctorEmail: widget.comment.email, isFromPageView: false)
                ));
              }
            },
            leading: widget.comment.imageUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(widget.comment.imageUrl!))
                : CircleAvatar(
                    backgroundColor: kMainColorLight,
                    child: Center(
                      child: Text(
                        AllFunctions.getFirstLetter(widget.comment.name),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
            title: Text(widget.comment.name),
            subtitle: Text(widget.comment.email),
            trailing: widget.currentUser.role == UserRole.Admin.name
                ? IconButton(
                    onPressed: (){
                      widget.deleteComment();
                    },
                    icon: Icon(Icons.delete_forever),
                  )
                : widget.currentUser.email == widget.comment.email
                    ? PopupMenuButton<int>(
                        itemBuilder: (context) => [
                          AllFunctions.createPopupMenuItem(1, "Update", Icons.update),
                          AllFunctions.createPopupMenuItem(2, "Delete", Icons.delete_forever),
                        ],
                        onSelected: (value) async {
                          switch (value) {
                            case 1:{
                              widget.updateComment();
                            }
                            break;

                            case 2:{
                              widget.deleteComment();
                            }
                            break;
                          }
                        },
                      )
                    : kSizeBoxEmpty,
          ),
          AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isClickComment = !isClickComment;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      widget.comment.comment,
                      // softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      maxLines: isClickComment ? 200 : 5,
                    ),
                  ),
                ),
              ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  AllFunctions.convertDate(widget.comment.date),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///////////////////////////
