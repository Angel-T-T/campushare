import 'package:flutter/material.dart';
import '../models/friend_request.dart';

class FriendRequestsInbox extends StatelessWidget {
  final List<FriendRequest> requests;
  final void Function(FriendRequest request) onAccept;
  final void Function(FriendRequest request) onReject;

  const FriendRequestsInbox({
    required this.requests,
    required this.onAccept,
    required this.onReject,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text('No tienes solicitudes de amistad.'));
    }
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(req.senderName),
            subtitle: Text(req.senderDescription),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  tooltip: 'Aceptar',
                  onPressed: () => onAccept(req),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Rechazar',
                  onPressed: () => onReject(req),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}