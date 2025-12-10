import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../models/user.dart'; // Removed unused import
import '../providers/auth_provider.dart';

class RoleRequestPage extends StatelessWidget {
  const RoleRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Perubahan Role'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final pendingRequests = authProvider.getAllUsersWithPendingRoleRequests();

          if (pendingRequests.isEmpty) {
            return const Center(
              child: Text('Tidak ada permintaan perubahan role yang tertunda.'),
            );
          }

          return ListView.builder(
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final user = pendingRequests[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Username: ${user.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Role Saat Ini: ${user.role}'),
                      Text('Meminta Role: ${user.requestedRole}'),
                      Text('Status: ${user.requestStatus}'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await authProvider.updateUserRoleAndStatus(
                                user,
                                user.requestedRole!,
                                'approved',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Permintaan disetujui!')),
                              );
                            },
                            child: const Text('Setujui'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () async {
                              await authProvider.updateUserRoleAndStatus(
                                user,
                                user.role, // Keep current role
                                'rejected',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Permintaan ditolak!')),
                              );
                            },
                            child: const Text('Tolak'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
