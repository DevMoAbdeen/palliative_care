import 'package:flutter/material.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/firebase/fb_notification.dart';
import 'package:palliative_care/functions.dart';
import '../../constants.dart';
import '../../firebase/fb_activity.dart';
import '../../firebase/fb_authentication.dart';
import '../../firebase/fb_comments.dart';
import '../../models/article.dart';
import '../../models/comment.dart';
import '../../models/user.dart';
import '../../components/main_widgets.dart';

class BottomSheetComments extends StatefulWidget {
  final Article article;
  final UserModel currentUser;

  const BottomSheetComments({Key? key, required this.article, required this.currentUser}) : super(key: key);

  @override
  State<BottomSheetComments> createState() => _BottomSheetCommentsState();
}

class _BottomSheetCommentsState extends State<BottomSheetComments> {
  TextEditingController commentController = TextEditingController();

  bool isClickCreate = false;
  bool isGettingComments = false;
  List<Comment> commentsOfArticle = [];
  int? commentIndexUpdate;

  getComments() async {
    setState(() {
      isGettingComments = true;
    });
    commentsOfArticle = await FbCommentsFunctions.getCommentsOfArticle(context, widget.article.articleId!);
    setState(() {
      isGettingComments = false;
    });
  }

  @override
  void initState() {
    getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isClickCreate || isGettingComments
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: kBackgroundColor,
            body: commentsOfArticle.isEmpty
                ? const Center(child: Text("No any comments"))
                // ? const Center(child: Text("لا يوجد أي تعليقات"))
                : Column(
                    children: [
                      Divider(
                        indent: MediaQuery.of(context).size.width / 3,
                        color: kMainColorLight,
                        thickness: 3,
                        endIndent: MediaQuery.of(context).size.width / 3,
                      ),
                      kSizeBoxH8,
                      Expanded(
                        child: ListView.builder(
                          itemCount: commentsOfArticle.length,
                          itemBuilder: (context, index) {
                            return ShowComment(
                              comment: commentsOfArticle[index],
                              currentUser: widget.currentUser,
                              updateComment: () {
                                commentController.text = commentsOfArticle[index].comment;
                                commentIndexUpdate = index;
                                setState(() {});
                              },
                              deleteComment: () {
                                showDialog(context: context, builder: (BuildContext context) {
                                  return AllFunctions.showDialogDelete(
                                    context, deleteWhat: "Comment",
                                    deleteFunction: () async {
                                      Navigator.pop(context);
                                      await FbCommentsFunctions.deleteComment(context, widget.article.articleId!, commentsOfArticle[index]);
                                      getComments();
                                      FbActivitiesFunctions.handleCommentActivity(context, widget.currentUser.email,
                                          DateTime.now().toString(), widget.article);
                                      FbArticlesFunctions.handleUpdateArticle(context, widget.article.articleId!, DateTime.now().toString());
                                    },
                                  );
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: widget.currentUser.role == UserRole.Admin.name
                ? kSizeBoxEmpty
                : Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      decoration: kMessageContainerDecoration,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              maxLines: 2,
                              minLines: 1,
                              decoration: kMessageTextFieldDecoration.copyWith(
                                  hintText: commentIndexUpdate != null
                                      ? "Update comment.."
                                      : "Your comment.."),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (commentIndexUpdate != null) {
                                String updatedComment = commentController.text.toString().trim();
                                if (updatedComment.isNotEmpty) {
                                  await FbCommentsFunctions.updateComment(context, widget.article.articleId!, commentsOfArticle, updatedComment, commentIndexUpdate!);
                                  getComments();

                                  commentController.clear();
                                  commentIndexUpdate = null;
                                  setState(() {});
                                  FbArticlesFunctions.handleUpdateArticle(context, widget.article.articleId!, DateTime.now().toString());
                                } else {
                                  commentIndexUpdate = null;
                                  setState(() {});
                                }
                              } else {
                                String commentWritten = commentController.text.trim();
                                if (commentWritten.isNotEmpty) {
                                  setState(() {
                                    isClickCreate = true;
                                  });
                                  Comment comment = Comment(name: widget.currentUser.name, email: widget.currentUser.email,
                                    role: widget.currentUser.role, imageUrl: widget.currentUser.imageUrl, comment: commentWritten,
                                    date: DateTime.now().toString(),
                                  );
                                  await FbCommentsFunctions.addComment(context, widget.article.articleId!, comment);
                                  FbActivitiesFunctions.handleCommentActivity(context, widget.currentUser.email,
                                      DateTime.now().toString(), widget.article, commentWritten);
                                  FbNotificationFunctions.sendNotificationComments(widget.article.articleId!,
                                      widget.article.doctor.name, widget.currentUser.name, commentWritten,
                                  );
                                  FbAuthentication.handleSubscribedTopic(context, widget.currentUser.email, widget.article.articleId!, true);
                                  FbArticlesFunctions.handleUpdateArticle(context, widget.article.articleId!, DateTime.now().toString());
                                  setState(() {
                                    commentController.clear();
                                    isClickCreate = false;
                                  });
                                  getComments();
                                }
                              }
                            },
                            icon: Icon(
                              commentIndexUpdate != null
                                  ? Icons.update
                                  : Icons.send,
                              color: kMainColorLight,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          );
  }
}
