import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_request.dart';

class FriendRequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(FriendRequest request) async {
    await _db.collection('friendRequests').doc(request.id).set(request.toMap());
  }

  Future<List<FriendRequest>> getReceivedRequests(String uid) async {
    final snapshot = await _db
        .collection('friendRequests')
        .where('receiverUid', isEqualTo: uid)
        .where('status', isEqualTo: FriendRequestStatus.pending.index)
        .get();

    return snapshot.docs.map((doc) => FriendRequest.fromMap(doc.data())).toList();
  }

  Future<List<FriendRequest>> getSentRequests(String uid) async {
    final snapshot = await _db
        .collection('friendRequests')
        .where('senderUid', isEqualTo: uid)
        .get();

    return snapshot.docs.map((doc) => FriendRequest.fromMap(doc.data())).toList();
  }

  Future<void> updateRequestStatus(String requestId, FriendRequestStatus status) async {
    await _db.collection('friendRequests').doc(requestId).update({'status': status.index});
  }
}