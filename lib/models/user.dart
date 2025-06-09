import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final List<String> interests; // materias, carreras, etc.
  final DateTime createdAt;
  final List<String> uploadedFileIds;
  final List<String> friendUids;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.interests = const [],
    required this.createdAt,
    this.uploadedFileIds = const [],
    this.friendUids = const [],
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      interests: List<String>.from(map['interests'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      uploadedFileIds: List<String>.from(map['uploadedFileIds'] ?? []),
      friendUids: List<String>.from(map['friendUids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'interests': interests,
      'createdAt': Timestamp.fromDate(createdAt),
      'uploadedFileIds': uploadedFileIds,
      'friendUids': friendUids,
    };
  }
}