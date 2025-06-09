import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';

class ProfileCard extends StatelessWidget {
  final AppUser user;
  final bool isMe;
  final VoidCallback? onEdit;

  const ProfileCard({
    required this.user,
    this.isMe = false,
    this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.photoUrl != null
                  ? CachedNetworkImageProvider(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(user.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (user.bio != null && user.bio!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(user.bio!, textAlign: TextAlign.center),
              ),
            if (user.interests.isNotEmpty)
              Wrap(
                spacing: 8,
                children: user.interests
                    .map((interest) => Chip(label: Text(interest)))
                    .toList(),
              ),
            if (isMe && onEdit != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: onEdit,
                  child: const Text("Editar perfil"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}