import 'package:cloud_firestore/cloud_firestore.dart';

enum FileType { document, image, guide, notes, other, apuntes, otro }

class FilePost {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String title;
  final String description;
  final FileType fileType;
  final String fileUrl;
  final List<String> tags; // materias, carreras, etc.
  final DateTime uploadedAt;
  final List<String> likesUids;

  FilePost({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    this.ownerPhotoUrl,
    required this.title,
    required this.description,
    required this.fileType,
    required this.fileUrl,
    this.tags = const [],
    required this.uploadedAt,
    this.likesUids = const [],
  });

  factory FilePost.fromMap(Map<String, dynamic> map) {
    return FilePost(
      id: map['id'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerPhotoUrl: map['ownerPhotoUrl'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      fileType: FileType.values[map['fileType'] ?? 0],
      fileUrl: map['fileUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      likesUids: List<String>.from(map['likesUids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'title': title,
      'description': description,
      'fileType': fileType.index,
      'fileUrl': fileUrl,
      'tags': tags,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'likesUids': likesUids,
    };
  }
}