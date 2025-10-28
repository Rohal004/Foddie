import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_navigator.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

/// Show a confirmation dialog and, if confirmed, sign out and navigate to Login.
Future<void> confirmAndLogout(BuildContext context) async {
  // Resolve an app-level context to access providers before any `await` so
  // we don't use the incoming `context` across async gaps (avoids analyzer
  // warning and potential runtime issues).
  final providerContext = appNavigatorKey.currentContext ?? context;
  final authProvider = Provider.of<AuthProvider>(
    providerContext,
    listen: false,
  );

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm logout'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  await authProvider.signOut();
  appNavigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
