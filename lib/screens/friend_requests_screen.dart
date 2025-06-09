import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_request_service.dart';
import '../services/user_service.dart';
import '../models/friend_request.dart';
import '../widgets/friend_requests_inbox.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequest> _requests = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'Usuario no autenticado.';
          _loading = false;
        });
        return;
      }
      _requests = await FriendRequestService().getReceivedRequests(currentUser.uid);
    } catch (e) {
      setState(() {
        _error = 'Error cargando solicitudes: $e';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _acceptRequest(FriendRequest req) async {
    setState(() => _loading = true);
    try {
      // Actualiza el estado de la solicitud
      await FriendRequestService().updateRequestStatus(req.id, FriendRequestStatus.accepted);

      // Actualiza las listas de amigos de ambos usuarios
      final userService = UserService();
      final sender = await userService.getUserById(req.senderUid);
      final receiver = await userService.getUserById(req.receiverUid);

      if (sender != null && receiver != null) {
        final updatedSenderFriends = List<String>.from(sender.friendUids)..add(receiver.uid);
        final updatedReceiverFriends = List<String>.from(receiver.friendUids)..add(sender.uid);

        await userService.updateUserProfile(sender.uid, {'friendUids': updatedSenderFriends});
        await userService.updateUserProfile(receiver.uid, {'friendUids': updatedReceiverFriends});
      }

      await _fetchRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada')),
      );
    } catch (e) {
      setState(() {
        _error = 'Error al aceptar solicitud: $e';
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _rejectRequest(FriendRequest req) async {
    setState(() => _loading = true);
    try {
      await FriendRequestService().updateRequestStatus(req.id, FriendRequestStatus.rejected);
      await _fetchRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada')),
      );
    } catch (e) {
      setState(() {
        _error = 'Error al rechazar solicitud: $e';
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: FriendRequestsInbox(
        requests: _requests,
        onAccept: _acceptRequest,
        onReject: _rejectRequest,
      ),
    );
  }
}