import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/file_service.dart';
import '../models/user.dart';
import '../models/file_post.dart';
import '../widgets/profile_card.dart';
import '../widgets/file_post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? user;
  List<FilePost> userFiles = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        setState(() {
          error = 'No hay usuario autenticado.';
          loading = false;
        });
        return;
      }
      user = await UserService().getUserById(firebaseUser.uid);
      if (user != null) {
        userFiles = await FileService().getFilesByUser(user!.uid);
      }
    } catch (e) {
      error = 'Error cargando el perfil: $e';
    }
    setState(() {
      loading = false;
    });
  }

  void _showEditProfileDialog() {
    final bioController = TextEditingController(text: user?.bio ?? '');
    final interestsController = TextEditingController(text: user?.interests.join(', ') ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: bioController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLength: 120,
                ),
                TextFormField(
                  controller: interestsController,
                  decoration: const InputDecoration(
                    labelText: 'Intereses/carreras (separados por coma)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await UserService().updateUserProfile(user!.uid, {
                  'bio': bioController.text.trim(),
                  'interests': interestsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                });
                Navigator.pop(context);
                _fetchProfile();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }
    if (user == null) {
      return const Center(child: Text('Usuario no encontrado.'));
    }
    return RefreshIndicator(
      onRefresh: _fetchProfile,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ProfileCard(
            user: user!,
            isMe: true,
            onEdit: _showEditProfileDialog,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Tus archivos subidos",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...userFiles.isEmpty
              ? [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Aún no has subido archivos.'),
            )
          ]
              : userFiles.map((file) => FilePostCard(filePost: file)).toList(),
        ],
      ),
    );
  }
}