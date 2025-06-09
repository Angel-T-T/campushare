import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/chat_item.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('No has iniciado sesión.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participantUids', arrayContains: currentUser.uid)
          .orderBy('lastMessageAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        final chats = snapshot.data?.docs ?? [];
        if (chats.isEmpty) {
          return const Center(child: Text('No tienes chats activos.'));
        }
        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final chat = chats[i].data();
            final otherNames = (chat['participantNames'] as List).where((n) =>
            n != currentUser.displayName && n != null && n.toString().isNotEmpty).toList();
            final otherPhotos = (chat['participantPhotoUrls'] as List?)?.where((url) => url != currentUser.photoURL && url != null).toList();
            return ChatItem(
              chatId: chat['id'],
              name: otherNames.isNotEmpty ? otherNames.join(', ') : 'Chat',
              lastMessage: chat['lastMessage'] as String?,
              avatarUrl: (otherPhotos != null && otherPhotos.isNotEmpty) ? otherPhotos.first : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatId: chat['id'],
                      chatName: otherNames.isNotEmpty ? otherNames.join(', ') : 'Chat',
                      avatarUrl: (otherPhotos != null && otherPhotos.isNotEmpty) ? otherPhotos.first : null,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}