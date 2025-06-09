import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatsForUser(String uid) {
    return _db
        .collection('chats')
        .where('participantUids', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesForChat(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': message['content'],
      'lastMessageAt': message['sentAt'],
    });
  }

  Future<String> createChat(List<String> participantUids, List<String> participantNames, List<String?> participantPhotoUrls) async {
    final ref = _db.collection('chats').doc();
    await ref.set({
      'id': ref.id,
      'participantUids': participantUids,
      'participantNames': participantNames,
      'participantPhotoUrls': participantPhotoUrls,
      'createdAt': Timestamp.now(),
      'lastMessage': null,
      'lastMessageAt': null,
    });
    return ref.id;
  }
}