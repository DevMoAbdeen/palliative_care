class Like {
  String articleId;
  String description;
  String date;

  Like(
      {required this.articleId, required this.description, required this.date});

  factory Like.fromMap(Map<String, dynamic> data) {
    return Like(
      articleId: data['articleId'],
      description: data['description'],
      date: data['date'],
    );
  }
}

////////////////////////////////

class Comment {
  String articleId;
  String description;
  String date;

  Comment(
      {required this.articleId, required this.description, required this.date});

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      articleId: data['articleId'],
      description: data['description'],
      date: data['date'],
    );
  }
}

class Other {
  String? id;
  String description;
  String date;

  Other({required this.id, required this.description, required this.date});

  factory Other.fromMap(Map<String, dynamic> data) {
    return Other(
      id: data['id'],
      description: data['description'],
      date: data['date'],
    );
  }
}
