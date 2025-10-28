import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_db_service.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final service = LocalDBService();
    final userId = auth.userId;
    final userEmail = auth.userEmail;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Orders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: service.getUserDetails(userId),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final user = snap.data;
                final displayName =
                    (user != null &&
                        (user['firstName'] ?? '').toString().isNotEmpty)
                    ? '${user['firstName']} ${user['lastName'] ?? ''}'.trim()
                    : (userEmail.isNotEmpty ? userEmail : 'Guest');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: $displayName'),
                    Text('Email: $userEmail'),
                    const SizedBox(height: 8),
                    Text('Address: ${user?['address'] ?? ''}'),
                    Text('City: ${user?['city'] ?? ''}'),
                    Text('Phone: ${user?['phone'] ?? ''}'),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
            const Text('Order History', style: TextStyle(fontSize: 18)),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: service.getUserOrders(userId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error fetching orders');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final orders = snapshot.data!;
                  if (orders.isEmpty) return const Text('No past orders.');
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) {
                      final order = orders[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Order Total: \$${order['total']}'),
                          subtitle: Text('Status: ${order['status']}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
