class TopicInArticle {
  String? topicId;
  String title;
  String description;

  TopicInArticle(
      {required this.topicId, required this.title, required this.description});

  factory TopicInArticle.fromArticle(Map<String, dynamic> data) {
    return TopicInArticle(
      topicId: data['id'],
      title: data['title'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toAddArticle(TopicInArticle topicInArticle) {
    return {
      "id": topicInArticle.topicId,
      "title": topicInArticle.title,
      "description": topicInArticle.description,
    };
  }
}
