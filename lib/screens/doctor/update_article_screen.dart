import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/firebase/fb_files.dart';
import 'package:palliative_care/models/article.dart';
import '../../components/display_files.dart';
import '../../components/main_widgets.dart';
import '../../constants.dart';
import '../../firebase/fb_notification.dart';
import '../../models/file.dart';

class UpdateArticleScreen extends StatefulWidget {
  final Article oldArticle;

  const UpdateArticleScreen({Key? key, required this.oldArticle})
      : super(key: key);

  @override
  State<UpdateArticleScreen> createState() => _UpdateArticleScreenState();
}

class _UpdateArticleScreenState extends State<UpdateArticleScreen> {
  TextEditingController articleTitleController = TextEditingController();
  TextEditingController articleDescriptionController = TextEditingController();

  bool articleTitleValidate = false;
  bool articleDescriptionValidate = false;

  bool isClickUpdate = false;

  List<SelectedFile> allImages = [];
  List<SelectedFile> allVideos = [];

  List allDownloadURLImages = [];
  List allDownloadURLVideos = [];

  @override
  void initState() {
    articleTitleController.text = widget.oldArticle.title;
    articleDescriptionController.text = widget.oldArticle.description;
    allDownloadURLImages = [...widget.oldArticle.images];
    allDownloadURLVideos = [...widget.oldArticle.videos];
    super.initState();
  }

  @override
  void dispose() {
    articleTitleController.dispose();
    articleDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: isClickUpdate
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              // "إلغاء",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ),
                          const Text(
                            "Update Article",
                            // "تعديل المقالة",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          TextButton(
                            child: const Text(
                              "Update",
                              // "تعديل",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                            onPressed: () async {
                              String articleTitle = articleTitleController.text.toString().trim();
                              String article = articleDescriptionController.text.toString().trim();

                              if (articleTitle.isEmpty || article.isEmpty) {
                                setState(() {
                                  articleTitleValidate = articleTitle.isEmpty;
                                  articleDescriptionValidate = article.isEmpty;
                                });
                              } else {
                                setState(() {
                                  isClickUpdate = true;
                                });
                                if (allImages.isNotEmpty) {
                                  for (int i = 0; i < allImages.length; i++) {
                                    String imageUrl = await FbFiles.uploadImage(context, allImages[i].file, allImages[i].name);
                                    if (!imageUrl.startsWith("Error: ") && imageUrl != "File is not valid") {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Image ${i + 1} has been uploaded"),
                                        duration: const Duration(milliseconds: 500),
                                      ));
                                      allDownloadURLImages.add(imageUrl);
                                    }
                                  }
                                }

                                if (allVideos.isNotEmpty) {
                                  for (int i = 0; i < allVideos.length; i++) {
                                    String videoUrl = await FbFiles.uploadVideo(context, allVideos[i].file, allVideos[i].name);
                                    if (!videoUrl.startsWith("Error: ") && videoUrl != "File is not valid") {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Video ${i + 1} has been uploaded"),
                                        duration: const Duration(milliseconds: 500),
                                      ));
                                      allDownloadURLVideos.add(videoUrl);
                                    }
                                  }
                                }

                                Article updatedArticle = Article(articleId: widget.oldArticle.articleId,
                                  title: articleTitle, description: article, topic: widget.oldArticle.topic,
                                  images: allDownloadURLImages, videos: allDownloadURLVideos,
                                  likes: widget.oldArticle.likes, doctor: widget.oldArticle.doctor, hidden: false,
                                  createdAt: widget.oldArticle.createdAt, updatedAt: DateTime.now().toString(),
                                );

                                bool isUpdated = await FbArticlesFunctions.updateArticle(context, updatedArticle);
                                setState(() {
                                  isClickUpdate = false;
                                });
                                if (isUpdated) {
                                  FbNotificationFunctions.sendNotificationArticle(
                                      widget.oldArticle.topic.topicId!,
                                      "Edited an article by Dr. ${widget.oldArticle.doctor.name}",
                                      "Article now titled $articleTitle");
                                  Navigator.pop(context, updatedArticle);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    MainWhiteContainer(
                      childWidget: Column(
                        children: [
                          TextFormField(
                            controller: articleTitleController,
                            minLines: 1,
                            maxLines: 2,
                            maxLength: 100,
                            keyboardType: TextInputType.text,
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Article title',
                              // hintText: 'عنوان المقالة',
                              errorText: articleTitleValidate
                                  ? 'Article title can\'t be empty'
                                  // ? 'لا يمكن للعنوان أن يكون فارغ'
                                  : null,
                              prefixIcon: const Icon(Icons.title),
                              prefixIconColor: Colors.grey,
                            ),
                            onChanged: (value) {
                              setState(() {
                                value.isNotEmpty
                                    ? articleTitleValidate = false
                                    : null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.article),
                      title: Text("Write Article"),
                      // title: Text("أكتب المقالة"),
                    ),
                    MainWhiteContainer(
                      childWidget: TextFormField(
                        controller: articleDescriptionController,
                        maxLines: 25,
                        minLines: 16,
                        decoration: kTextFieldDecoration.copyWith(
                          contentPadding: const EdgeInsets.all(8),
                          errorText: articleDescriptionValidate
                              ? 'Write the article !!'
                              // ? 'أكتب المقالة !!'
                              : null,
                          labelText: 'Article...',
                          // labelText: 'المقالة...',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            value.isNotEmpty
                                ? articleDescriptionValidate = false
                                : null;
                          });
                        },
                      ),
                    ),
                    allDownloadURLImages.isEmpty && allDownloadURLVideos.isEmpty
                        ? kSizeBoxEmpty
                        : Container(
                            color: Colors.white,
                            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < allDownloadURLImages.length; i++) ...{
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              allDownloadURLImages.removeAt(i);
                                            });
                                          },
                                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                                ShowImageScreen(uri: allDownloadURLImages[i], isWantDownload: false)
                                            ));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 8, bottom: 8),
                                            height: 50,
                                            width: 50,
                                            color: Colors.grey,
                                            child: Hero(
                                                tag: allDownloadURLImages[i],
                                                child: Image.network(allDownloadURLImages[i]),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  },
                                  const SizedBox(width: 24),
                                  for (int i = 0; i < allDownloadURLVideos.length; i++) ...{
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              allDownloadURLVideos.removeAt(i);
                                            });
                                          },
                                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                                ShowVideoScreen(videoUrl: allDownloadURLVideos[i], videoPath: null),
                                            ));
                                          },
                                          child: Container(
                                              margin: const EdgeInsets.only(right: 8, bottom: 8),
                                              height: 50,
                                              width: 50,
                                              color: Colors.grey,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.play_circle,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                              ),
                                          ),
                                        )
                                      ],
                                    )
                                  },
                                ],
                              ),
                            ),
                          ),
                    MainWhiteContainer(
                      childWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (allImages.length + allDownloadURLImages.length < 5) {
                                ImagePicker imagePicker = ImagePicker();
                                XFile? file = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);

                                if (file != null) {
                                  bool isSelectImageBefore = false;
                                  for (SelectedFile image in allImages) {
                                    if (file.path.substring(file.path.lastIndexOf("/")) ==
                                        image.file.path.substring(image.file.path.lastIndexOf("/"))) {
                                      isSelectImageBefore = true;
                                    }
                                  }

                                  if (isSelectImageBefore) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('You choose this image before !!'),
                                        // content: Text('إخترت هذه الصورة من قبل !'),
                                    ));
                                  } else {
                                    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
                                    SelectedFile image = SelectedFile(file, imageName);
                                    allImages.add(image);
                                    setState(() {});
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('You cannot select more images!'),
                                    // content: Text('لا يمكنك إختيار أكثر من 5 صور'),
                                ));
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Icon(
                                  Icons.add_circle,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                                kSizeBoxW16,
                                Text(
                                  "Add image",
                                  // "إضافة صورة",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          allImages.isNotEmpty ? kSizeBoxH8 : const SizedBox(),
                          allImages.isNotEmpty
                              ? ExpansionTile(
                                  title: const Text("Show Images selected"),
                                  // title: const Text("عرض الصور الذي اخترتها"),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: allImages.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            ShowImage(
                                              selectedImage: allImages[index],
                                              funOnClickShow: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                  return DetailScreen(imagePath: allImages[index].file.path);
                                                }));
                                              },
                                              funOnClickDelete: () {
                                                allImages.removeAt(index);
                                                setState(() {});
                                              },
                                            ),
                                            index != allImages.length - 1
                                                ? kDivider
                                                : const SizedBox(),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    MainWhiteContainer(
                      childWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (allVideos.length + allDownloadURLVideos.length < 5) {
                                ImagePicker imagePicker = ImagePicker();
                                XFile? file = await imagePicker.pickVideo(source: ImageSource.gallery);

                                if (file != null) {
                                  bool isSelectVideoBefore = false;
                                  for (SelectedFile video in allVideos) {
                                    if (file.path.substring(file.path.lastIndexOf("/")) ==
                                        video.file.path.substring(video.file.path.lastIndexOf("/"))) {
                                      isSelectVideoBefore = true;
                                    }
                                  }

                                  if (isSelectVideoBefore) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('You choose this video before !!'),
                                        // content: Text('إخترت هذا الفيديو من قبل !!'),
                                    ));
                                  } else {
                                    String videoName = DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString();
                                    SelectedFile video =
                                        SelectedFile(file, videoName);
                                    allVideos.add(video);
                                    setState(() {});
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('You cannot select more videos!'),
                                  // content: Text('لا يمكنك إختيار أكثر من 5 فيديوهات'),
                                ));
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Icon(
                                  Icons.add_circle,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                                kSizeBoxW16,
                                Text(
                                  "Add video",
                                  // "إضافة فيديو",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          allVideos.isNotEmpty ? kSizeBoxH8 : const SizedBox(),
                          allVideos.isNotEmpty
                              ? ExpansionTile(
                                  title: const Text("Show Videos selected"),
                                  // title: const Text("عرض الفيديوهات الذي اخترتها"),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: allVideos.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            ShowSelectedVideos(
                                              selectedVideo: allVideos[index],
                                              funOnClickShow: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                  return ShowVideoScreen(videoUrl: null, videoPath: allVideos[index].file.path);
                                                }));
                                              },
                                              funOnClickDelete: () {
                                                allVideos.removeAt(index);
                                                setState(() {});
                                              },
                                            ),
                                            index != allVideos.length - 1
                                                ? kDivider
                                                : const SizedBox(),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
