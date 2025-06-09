import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/friend_request.dart';
import '../services/user_service.dart';
import '../models/file_post.dart'; // Solo una vez
import '../services/file_service.dart'; // Solo una vez
import '../services/friend_request_service.dart';
import '../widgets/profile_card.dart';
import '../widgets/file_post_card.dart';

class OtherProfileScreen extends StatefulWidget {
  final String userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  AppUser? user;
  List<FilePost> userFiles = [];
  bool loading = true;
  String? error;
  bool requestSent = false;
  bool isFriend = false;

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
      user = await UserService().getUserById(widget.userId);
      if (user != null) {
        userFiles = await FileService().getFilesByUser(user!.uid);

        // Verifica si ya es amigo
        // Aquí podrías obtener el UID actual del usuario autenticado (ajusta si usas provider o auth global)
        // Ejemplo básico:
        // final currentUid = FirebaseAuth.instance.currentUser?.uid;
        // if (currentUid != null) {
        //   isFriend = user!.friendUids.contains(currentUid);
        // }

        // Lógica adicional para saber si ya enviaste una solicitud de amistad (ajusta a tu flujo)
        // final requests = await FriendRequestService().getSentRequests(currentUid!);
        // requestSent = requests.any((r) => r.receiverUid == user!.uid);
      }
    } catch (e) {
      error = 'Error cargando el perfil: $e';
    }
    setState(() {
      loading = false;
    });
  }

  void _sendFriendRequest() async {
    setState(() => loading = true);
    try {
      // Debes obtener el UID y datos del usuario actual (autenticado)
      // Aquí hay un ejemplo (ajusta según tu autenticación real):
      // final currentUid = FirebaseAuth.instance.currentUser?.uid;
      // final currentUser = await UserService().getUserById(currentUid!);

      // Ejemplo para pruebas:
      final currentUser = null; // Reemplaza por el usuario real

      if (currentUser == null || user == null) {
        setState(() {
          loading = false;
          error = "No se pudo enviar la solicitud.";
        });
        return;
      }

      final request = FriendRequest(
        id: "${currentUser.uid}_${user!.uid}",
        senderUid: currentUser.uid,
        receiverUid: user!.uid,
        senderName: currentUser.displayName,
        senderDescription: currentUser.bio ?? "",
        sentAt: DateTime.now(),
        status: FriendRequestStatus.pending,
      );
      await FriendRequestService().sendFriendRequest(request);
      setState(() {
        requestSent = true;
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada')),
      );
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error enviando la solicitud: $e';
      });
    }
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
            isMe: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (!isFriend && !requestSent)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Agregar amigo'),
                    onPressed: _sendFriendRequest,
                  ),
                if (requestSent)
                  const Chip(
                    avatar: Icon(Icons.hourglass_empty, size: 16),
                    label: Text('Solicitud enviada'),
                  ),
                if (isFriend)
                  const Chip(
                    avatar: Icon(Icons.check, size: 16, color: Colors.green),
                    label: Text('Ya son amigos'),
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Archivos subidos",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...userFiles.isEmpty
              ? [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Este usuario no ha subido archivos.'),
            )
          ]
              : userFiles.map((file) => FilePostCard(filePost: file)).toList(),
        ],
      ),
    );
  }
}