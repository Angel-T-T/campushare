import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest {
  final String id;
  final String senderUid;
  final String receiverUid;
  final String senderName;
  final String senderDescription;
  final DateTime sentAt;
  final FriendRequestStatus status;

  FriendRequest({
    required this.id,
    required this.senderUid,
    required this.receiverUid,
    required this.senderName,
    required this.senderDescription,
    required this.sentAt,
    this.status = FriendRequestStatus.pending,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'] ?? '',
      senderUid: map['senderUid'] ?? '',
      receiverUid: map['receiverUid'] ?? '',
      senderName: map['senderName'] ?? '',
      senderDescription: map['senderDescription'] ?? '',
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      status: FriendRequestStatus.values[map['status'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'senderName': senderName,
      'senderDescription': senderDescription,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status.index,
    };
  }
}