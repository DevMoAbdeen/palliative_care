import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palliative_care/constants.dart';
import 'package:palliative_care/firebase/fb_activity.dart';
import 'package:palliative_care/firebase/fb_articles.dart';
import 'package:palliative_care/firebase/fb_authentication.dart';
import 'package:palliative_care/firebase/fb_files.dart';
import 'package:palliative_care/firebase/fb_notification.dart';
import 'package:palliative_care/models/article.dart';
import 'package:palliative_care/models/doctor_create_article.dart';
import 'package:palliative_care/models/topic_in_article.dart';
import 'package:palliative_care/models/user.dart';
import 'package:provider/provider.dart';
import '../../components/display_files.dart';
import '../../components/main_widgets.dart';
import '../../firebase/fb_topics.dart';
import '../../models/file.dart';
import '../../models/topic.dart';
import '../../statemanagment/provider_topics.dart';
import '../../statemanagment/provider_user.dart';
import '../authentication/login_and_signup_screen.dart';

class NewArticleScreen extends StatefulWidget {
  static const String id = "NewArticleScreen";

  const NewArticleScreen({Key? key}) : super(key: key);

  @override
  State<NewArticleScreen> createState() => _NewArticleScreenState();
}

class _NewArticleScreenState extends State<NewArticleScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController topicNameController = TextEditingController();
  TextEditingController topicDescriptionController = TextEditingController();
  TextEditingController articleTitleController = TextEditingController();
  TextEditingController articleController = TextEditingController();

  bool topicTitleValidate = false;
  bool topicDescriptionValidate = false;
  bool articleTitleValidate = false;
  bool articleValidate = false;

  bool isClickCreate = false;

  List<SelectedFile> allImages = [];
  List<SelectedFile> allVideos = [];
  String topicNameWritten = "";
  List<Topic> allTopics = [];
  List<Topic> topicsContainName = [];
  Topic? selectedTopic;
  Topic? newTopic;
  List<String> allDownloadURLImages = [];
  List<String> allDownloadURLVideos = [];
  DoctorModel? currentDoctor;

  getAllTopics() async {
    allTopics = await FbTopicsFunctions.getAllTopics(context);
    Provider.of<TopicsProvider>(context, listen: false).setDataTopics(allTopics);
  }

  @override
  void initState() {
    currentDoctor = Provider.of<UserProvider>(context, listen: false).getCurrentDoctor;
    if (currentDoctor == null) {
      FbAuthentication.logoutUser();
      Navigator.pushReplacementNamed(context, LoginAndSignupScreen.id);
    }
    getAllTopics();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    topicNameController.dispose();
    topicDescriptionController.dispose();
    articleTitleController.dispose();
    articleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedTopic != null || newTopic != null) {
      if (selectedTopic != null) {
        topicNameController.text = selectedTopic!.title.toString();
        topicDescriptionController.text = selectedTopic!.description.toString();
      } else {
        topicNameController.text = newTopic!.title.toString();
      }
      topicTitleValidate = false;
      setState(() {});
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: isClickCreate
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
                            "New Article",
                            // "مقالة جديدة",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          TextButton(
                            child: const Text(
                              "Create",
                              // "إنشاء",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                            onPressed: () async {
                              String topicTitle = topicNameController.text.toString().trim();
                              String topicDescription = topicDescriptionController.text.toString().trim();
                              String articleTitle = articleTitleController.text.toString().trim();
                              String article = articleController.text.toString().trim();

                              if (topicTitle.isEmpty || articleTitle.isEmpty || article.isEmpty || topicDescription.isEmpty) {
                                setState(() {
                                  topicTitleValidate = topicTitle.isEmpty;
                                  topicDescriptionValidate = topicDescription.isEmpty;
                                  articleTitleValidate = articleTitle.isEmpty;
                                  articleValidate = article.isEmpty;
                                  // article.isEmpty ? articleValidate = true : articleValidate = false;
                                });
                              } else {
                                setState(() {
                                  isClickCreate = true;
                                });
                                Topic? createdTopic;
                                if (newTopic != null) {
                                  newTopic!.description = topicDescription;
                                  createdTopic = await FbTopicsFunctions.createNewTopic(context, newTopic!);
                                  FbActivitiesFunctions.handleTopicActivity(context, currentDoctor!.email, newTopic!.title, DateTime.now().toString(), true);
                                  Provider.of<TopicsProvider>(context, listen: false).addTopic(createdTopic!);
                                }

                                Topic articleTopic = newTopic != null
                                    ? createdTopic!
                                    : selectedTopic!;

                                if (allImages.isNotEmpty) {
                                  for (int i = 0; i < allImages.length; i++) {
                                    String imageUrl = await FbFiles.uploadImage(context, allImages[i].file, allImages[i].name);
                                    if (!imageUrl.startsWith("Error: ") && imageUrl != "File is not valid") {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Image ${i + 1} has been uploaded"),
                                        duration: const Duration(seconds: 1),
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
                                      ));
                                      allDownloadURLVideos.add(videoUrl);
                                    }
                                  }
                                }
                                String date = DateTime.now().toString();

                                Doctor doctor = Doctor(name: currentDoctor!.name, email: currentDoctor!.email,
                                    specialty: currentDoctor!.specialty, imageUrl: currentDoctor!.imageUrl,
                                );
                                TopicInArticle topicArticle = TopicInArticle(topicId: articleTopic.topicId,
                                    title: articleTopic.title, description: articleTopic.description,
                                );

                                Article newArticle = Article(articleId: null, title: articleTitle, description: article,
                                  topic: topicArticle, images: allDownloadURLImages, videos: allDownloadURLVideos,
                                  likes: [], doctor: doctor, hidden: false, createdAt: date, updatedAt: date,
                                );

                                bool isArticleCreate = await FbArticlesFunctions.createNewArticle(context, newArticle);
                                FbActivitiesFunctions.handleArticleActivity(context, currentDoctor!.email, newArticle.title, date, true);
                                setState(() {
                                  isClickCreate = false;
                                });
                                if (isArticleCreate) {
                                  FbNotificationFunctions.sendNotificationArticle(articleTopic.topicId!,
                                      "New article on topic ${articleTopic.title}",
                                    "Dr.${newArticle.doctor.name} published an article titled ${newArticle.title}",
                                  );
                                  Navigator.pop(context);
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
                            controller: topicNameController,
                            readOnly: true,
                            minLines: 1,
                            maxLines: 2,
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Topic title',
                              // hintText: 'عنوان الموضوع',
                              errorText: topicTitleValidate
                                  ? 'You must choose a topic'
                                  // ? 'يجب أن تختار موضوع'
                                  : null,
                              prefixIcon: const Icon(Icons.category),
                              prefixIconColor: Colors.grey,
                              suffixIcon: const Icon(Icons.error_outline),
                              suffixIconColor: Colors.blue,
                            ),
                            onTap: () {
                              allTopicsBottomSheet();
                            },
                          ),
                          TextFormField(
                            controller: topicDescriptionController,
                            readOnly: selectedTopic != null ? true : false,
                            minLines: 1,
                            maxLines: 3,
                            maxLength: 150,
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Topic description',
                              // hintText: 'وصف الموضوع',
                              errorText: topicDescriptionValidate
                                  ? 'Write topic description'
                                  // ? 'أكتب وصف الموضوع!'
                                  : null,
                              prefixIcon: const Icon(Icons.category_outlined),
                              prefixIconColor: Colors.grey,
                              // suffixIcon: const Icon(Icons.done),
                              // suffixIconColor: Colors.blue,
                            ),
                            onChanged: (value) {
                              setState(() {
                                value.isNotEmpty
                                    ? topicDescriptionValidate = false
                                    : null;
                              });
                            },
                          ),
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
                                  // ? 'لا يمكن للعنوان أن يكون فارغ!!'
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
                        controller: articleController,
                        maxLines: 22,
                        minLines: 16,
                        decoration: kTextFieldDecoration.copyWith(
                          contentPadding: const EdgeInsets.all(8),
                          errorText: articleValidate ? 'Write the article !!' : null,
                          // errorText: articleValidate ? 'أكتب المقالة !!' : null,
                          hintText: 'Article...',
                          // hintText: 'المقالة...',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            value.isNotEmpty ? articleValidate = false : null;
                          });
                        },
                      ),
                    ),
                    MainWhiteContainer(
                      childWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (allImages.length < 5) {
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
                                        content: Text('You choose this image before !!')
                                        // content: Text("إخترت هذه الصورة من قبل !")
                                    ));
                                  } else {
                                    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
                                    SelectedFile image = SelectedFile(file, imageName);
                                    allImages.add(image);
                                    setState(() {});
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
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
                              if (allVideos.length < 5) {
                                ImagePicker imagePicker = ImagePicker();
                                XFile? file = await imagePicker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 15));

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
                                    String videoName = DateTime.now().millisecondsSinceEpoch.toString();
                                    SelectedFile video = SelectedFile(file, videoName);
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

  void allTopicsBottomSheet() {
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return FractionallySizedBox(
              heightFactor: 0.92,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ),
                          const Text(
                            "Select Topic",
                            // "إختيار موضوع",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: TextField(
                        controller: searchController,
                        maxLength: 50,
                        onChanged: (value) {
                          topicNameWritten = value;
                          topicsContainName = allTopics.where((element) =>
                            (element.title.toUpperCase().contains(value.toUpperCase()) || element.doctorEmailCreated.contains(value)),
                          ).toList();
                          setStateBottomSheet(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "search or create topic...",
                          // hintText: "إبحث أو أنشئ موضوع...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              searchController.clear();
                              topicNameWritten = "";
                              setState(() {});
                              setStateBottomSheet(() {});
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                      ),
                    ),
                    kDivider,
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              topicNameWritten.isNotEmpty
                                  ? "\"$topicNameWritten\""
                                  : "",
                            ),
                          ),
                        ),
                        topicNameWritten.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  selectedTopic = null;
                                  newTopic = Topic(topicId: null, title: topicNameWritten, description: "",
                                    doctorEmailCreated: currentDoctor!.email, createdAt: DateTime.now().toString(),
                                    updatedAt: DateTime.now().toString(),
                                  );
                                  searchController.clear();
                                  topicNameWritten = "";
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Colors.blue,
                                ),
                              )
                            : kSizeBoxEmpty,
                      ],
                    ),
                    kDivider,
                    allTopics.isNotEmpty || topicNameWritten.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: topicNameWritten.isEmpty
                                  ? allTopics.length
                                  : topicsContainName.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    newTopic = null;
                                    selectedTopic = topicNameWritten.isEmpty
                                        ? allTopics[index]
                                        : topicsContainName[index];

                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                  child: ListTile(
                                    leading: const Icon(Icons.category),
                                    title: Text(
                                      topicNameWritten.isEmpty
                                          ? allTopics[index].title.toString()
                                          : topicsContainName[index].title,
                                    ),
                                    subtitle: Text(
                                      topicNameWritten.isEmpty
                                          ? allTopics[index].doctorEmailCreated.toString()
                                          : topicsContainName[index].doctorEmailCreated,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Expanded(
                            child: Center(
                              child: Text("No any topics"),
                              // child: Text("لا يوجد أي مواضيع"),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
