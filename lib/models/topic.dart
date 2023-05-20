import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  String? topicId;
  String title;
  String description;
  String doctorEmailCreated;
  String createdAt;
  String updatedAt;

  Topic(
      {required this.topicId,
      required this.title,
      required this.description,
      required this.doctorEmailCreated,
      required this.createdAt,
      required this.updatedAt});

  factory Topic.fromFirebase(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Topic(
      topicId: snapshot.id,
      title: data?['title'],
      description: data?['description'],
      doctorEmailCreated: data?['doctorEmailCreated'],
      createdAt: data?['createdAt'],
      updatedAt: data?['updatedAt'],
    );
  }

  Map<String, dynamic> toFirebase([String? id]) {
    if (id != null) {
      return {
        "id": id,
        "title": title,
        "description": description,
        "doctorEmailCreated": doctorEmailCreated,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
    } else {
      return {
        "title": title,
        "description": description,
        "doctorEmailCreated": doctorEmailCreated,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
    }
  }

  //////////////////////////////

  Map<String, dynamic> toAddArticle(Topic topic) {
    return {
      "id": topic.topicId,
      "title": topic.title,
      "description": topic.description,
    };
  }
}
