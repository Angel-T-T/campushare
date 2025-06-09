import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final String chatId;
  final String name;
  final String? lastMessage;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const ChatItem({
    required this.chatId,
    required this.name,
    this.lastMessage,
    this.avatarUrl,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: avatarUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl!))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(lastMessage ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}