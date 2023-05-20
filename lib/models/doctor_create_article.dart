class Doctor {
  String name;
  String email;
  String specialty;
  String? imageUrl;

  Doctor({
    required this.name,
    required this.email,
    required this.specialty,
    required this.imageUrl,
  });

  factory Doctor.fromArticle(Map<String, dynamic> data) {
    return Doctor(
      name: data['name'],
      email: data['email'],
      specialty: data['specialty'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toArticle() {
    return {
      "name": name,
      "email": email,
      "specialty": specialty,
      "imageUrl": imageUrl,
    };
  }
}
