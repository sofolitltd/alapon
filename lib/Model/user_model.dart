import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String mobile;
  final String email;
  final String image;
  final Timestamp timestamp;

  UserModel({
    required this.uid,
    required this.name,
    required this.mobile,
    required this.email,
    required this.image,
    required this.timestamp,
  });

//
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'],
        name: json['name'],
        mobile: json['mobile'],
        email: json['email'],
        image: json['image'],
        timestamp: json['timestamp'],
      );

//
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'image': image,
        'timeStamp': timestamp,
      };
}
