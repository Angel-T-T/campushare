import 'package:flutter/material.dart';

class UploadButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const UploadButton({required this.onPressed, this.label = "Subir archivo", super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}