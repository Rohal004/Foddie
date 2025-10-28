import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import '../services/local_db_service.dart';
import '../screens/home_screen.dart';
import '../app_navigator.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final service = LocalDBService();

    final items = cart.items.values.toList();
    final total = cart.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final it = items[i];
                  final qty = cart.quantityFor(it.id);
                  return ListTile(
                    title: Text(it.name),
                    subtitle: Text('Qty: ${qty == 0 ? 1 : qty}'),
                    trailing: Text(
                      '\$${(it.price * (qty == 0 ? 1 : qty)).toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Simple payment form fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Cardholder name'),
            ),
            const SizedBox(height: 8),
            // Note: In production you'd use a PCI-compliant SDK (e.g. Stripe's card field).
            TextField(
              decoration: const InputDecoration(
                labelText: 'Card number (demo only)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'MM/YY'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'CVC'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading || cart.items.isEmpty
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        // capture messenger and navigator before awaiting
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final payment = PaymentService();
                          await payment.makePayment(total.toInt(), 'usd');

                          // prepare expanded items according to quantities
                          final expanded = cart.items.entries
                              .expand(
                                (e) => List.filled(
                                  (cart.quantityFor(e.key) == 0
                                      ? 1
                                      : cart.quantityFor(e.key)),
                                  e.value,
                                ),
                              )
                              .toList();

                          await service.placeOrder(
                            auth.userId,
                            expanded,
                            total,
                          );
                          cart.clearCart();

                          // navigate back to Home clearing stack and then
                          // show a confirmation dialog on the fresh Home screen
                          await appNavigatorKey.currentState
                              ?.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                                (route) => false,
                              );

                          // Show a dialog on top of the Home route by pushing a
                          // non-opaque route through the navigator state. This
                          // avoids using the build context across async gaps.
                          await appNavigatorKey.currentState?.push(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (ctx, a1, a2) => AlertDialog(
                                title: const Text('Order placed'),
                                content: const Text(
                                  'Your order is placed successfully.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Payment failed: $e'),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator.adaptive(),
                      )
                    : const Text('Pay Now'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payments are demo-only. Replace with a proper payment SDK/setup for production.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
