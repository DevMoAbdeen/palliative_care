import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palliative_care/models/doctor_create_article.dart';
import 'package:palliative_care/models/topic_in_article.dart';

class Article {
  String? articleId;
  String title;
  String description;
  TopicInArticle topic;
  List<dynamic> images;
  List<dynamic> videos;
  List<dynamic> likes;
  Doctor doctor;
  bool hidden;
  String createdAt;
  String updatedAt;

  Article({
    required this.articleId,
    required this.title,
    required this.description,
    required this.topic,
    required this.images,
    required this.videos,
    required this.likes,
    required this.doctor,
    required this.hidden,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Article(
      articleId: snapshot.id,
      title: data?['title'],
      description: data?['description'],
      topic: TopicInArticle.fromArticle(data?['topic']),
      images: data?['images'],
      videos: data?['videos'],
      likes: data?['likes'],
      doctor: Doctor.fromArticle(data?['doctor']),
      hidden: data?['hidden'],
      createdAt: data?['createdAt'],
      updatedAt: data?['updatedAt'],
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      "title": title,
      "description": description,
      "topic": topic.toAddArticle(topic),
      "images": images,
      "videos": videos,
      "likes": likes,
      "doctor": doctor.toArticle(),
      "hidden": hidden,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
