import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/file_post.dart';

class FileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadFileAndCreatePost({
    required File file,
    required String uploaderUid,
    required String uploaderName,
    required String title,
    required String description,
    required List<String> tags,
    required FileType fileType,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final ref = _storage.ref().child('uploads/$fileName');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    final post = FilePost(
      id: _db.collection('filePosts').doc().id,
      ownerUid: uploaderUid,
      ownerName: uploaderName,
      title: title,
      description: description,
      tags: tags,
      fileType: fileType,
      fileUrl: downloadUrl,
      uploadedAt: DateTime.now(),
    );
    await _db.collection('filePosts').doc(post.id).set(post.toMap());
  }

  Future<List<FilePost>> getFilesByTags(List<String> tags) async {
    // Cambia el tipo de la variable a 'var' para evitar el error de tipo
    Query<Map<String, dynamic>> query = _db.collection('filePosts');
    if (tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => FilePost.fromMap(doc.data())).toList();
  }

  Future<List<FilePost>> getFilesByUser(String uid) async {
    final snapshot = await _db
        .collection('filePosts')
        .where('ownerUid', isEqualTo: uid)
        .get();
    return snapshot.docs.map((doc) => FilePost.fromMap(doc.data())).toList();
  }

}