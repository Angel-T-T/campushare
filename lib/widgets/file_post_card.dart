import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/file_post.dart';

class FilePostCard extends StatelessWidget {
  final FilePost filePost;
  final VoidCallback? onTap;

  const FilePostCard({required this.filePost, this.onTap, super.key});

  String _fileTypeToString(FileType type) {
    switch (type) {
      case FileType.document: return "Documento";
      case FileType.image: return "Imagen";
      case FileType.guide: return "Guía";
      case FileType.notes: return "Apuntes";
      default: return "Otro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        onTap: onTap,
        leading: filePost.fileType == FileType.image
            ? CachedNetworkImage(
          imageUrl: filePost.fileUrl,
          width: 50, height: 50, fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
        )
            : const Icon(Icons.insert_drive_file, size: 40),
        title: Text(filePost.title),
        subtitle: Text(filePost.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_fileTypeToString(filePost.fileType)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                Text(" ${filePost.likesUids.length}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}