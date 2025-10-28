import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_db_service.dart';
import '../providers/auth_provider.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _address.dispose();
    _city.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue(String userId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final service = LocalDBService();
    final details = {
      'firstName': _first.text.trim(),
      'lastName': _last.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
      'phone': _phone.text.trim(),
    };
    await service.updateUserDetails(userId, details);
    setState(() => _loading = false);
    // Navigate to payment screen
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Shipping / Billing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: LocalDBService().getUserDetails(userId),
                builder: (ctx, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user = snap.data;
                  if (user != null) {
                    _first.text = (user['firstName'] ?? '').toString();
                    _last.text = (user['lastName'] ?? '').toString();
                    _address.text = (user['address'] ?? '').toString();
                    _city.text = (user['city'] ?? '').toString();
                    _phone.text = (user['phone'] ?? '').toString();
                  }
                  return Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _first,
                          decoration: const InputDecoration(
                            labelText: 'First name',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _last,
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _address,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _city,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () => _saveAndContinue(userId),
                                child: const Text('Continue to Payment'),
                              ),
                      ],
                    ),
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
