import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../app_navigator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final success = await auth.signup(email.text, password.text);
                if (!mounted) return;
                if (success) {
                  // After account creation, route user to the login screen
                  // and show a message prompting them to login with their
                  // newly created credentials.
                  appNavigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        infoMessage:
                            'Your account has been created. Please login.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
