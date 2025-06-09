import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<List<AppUser>> searchUsers(String query) async {
    final snapshot = await _db
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
  }

  Future<List<AppUser>> getUsersByUids(List<String> uids) async {
    if (uids.isEmpty) return [];
    final snapshot = await _db.collection('users').where('uid', whereIn: uids).get();
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
  }
}