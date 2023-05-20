import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palliative_care/constants.dart';

class UserModel {
  String? imageUrl;
  String name;
  String email;
  String address;
  String birthdate;
  String mobileNumber;
  String role;
  String token;
  List subscribedTopics;

  UserModel({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.address,
    required this.birthdate,
    required this.mobileNumber,
    required this.role,
    required this.token,
    required this.subscribedTopics,
  });

  factory UserModel.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserModel(
      // userId: snapshot.id,
      imageUrl: data?['imageUrl'],
      name: data?['name'],
      email: data?['email'],
      address: data?['address'],
      birthdate: data?['birthdate'],
      mobileNumber: data?['mobile'],
      role: data?['role'],
      token: data?['token'],
      subscribedTopics: data?['subscribedTopics'],
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      "imageUrl": imageUrl,
      "name": name,
      "email": email,
      "address": address,
      "birthdate": birthdate,
      "mobile": mobileNumber,
      "role": role,
      "token": token,
      "subscribedTopics": subscribedTopics,
    };
  }
}

class DoctorModel {
  String? imageUrl;
  String name;
  String email;
  String specialty;
  String address;
  String birthdate;
  String mobileNumber;
  String token;
  List subscribedTopics;

  DoctorModel({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.specialty,
    required this.address,
    required this.birthdate,
    required this.mobileNumber,
    required this.token,
    required this.subscribedTopics,
  });

  factory DoctorModel.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return DoctorModel(
      // userId: snapshot.id,
      imageUrl: data?['imageUrl'],
      name: data?['name'],
      email: data?['email'],
      specialty: data?['specialty'],
      address: data?['address'],
      birthdate: data?['birthdate'],
      mobileNumber: data?['mobile'],
      token: data?['token'],
      subscribedTopics: data?['subscribedTopics'],
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      "imageUrl": imageUrl,
      "name": name,
      "email": email,
      "specialty": specialty,
      "address": address,
      "role": UserRole.Doctor.name,
      "birthdate": birthdate,
      "mobile": mobileNumber,
      "token": token,
      "subscribedTopics": subscribedTopics,
    };
  }
}
