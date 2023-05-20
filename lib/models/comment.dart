class Comment {
  String name;
  String email;
  String role;
  String comment;
  String date;
  String? imageUrl;

  Comment(
      {required this.name,
      required this.email,
      required this.role,
      required this.comment,
      required this.date,
      required this.imageUrl});

  factory Comment.fromFirebase(Map<String, dynamic> data) {
    return Comment(
      name: data['name'],
      email: data['email'],
      role: data['role'],
      comment: data['comment'],
      date: data['date'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      "name": name,
      "email": email,
      "role": role,
      "comment": comment,
      "date": date,
      "imageUrl": imageUrl,
    };
  }
}
