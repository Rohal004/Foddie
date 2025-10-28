import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    // LocalDBService will be used from the payment screen when placing orders.

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text("No items in cart"))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: cart.items.values.map((item) {
                      final qty = cart.quantityFor(item.id);
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          'Unit: \$${item.price.toStringAsFixed(2)}',
                        ),
                        trailing: SizedBox(
                          width: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  cart.decreaseQuantity(item.id);
                                },
                              ),
                              Text(
                                qty.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  cart.increaseQuantity(item.id);
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${(item.price * (qty == 0 ? 1 : qty)).toStringAsFixed(2)}',
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Remove',
                                onPressed: () async {
                                  // Capture messenger before awaiting to avoid
                                  // using BuildContext across async gaps.
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Remove item'),
                                      content: Text(
                                        'Remove ${item.name} from cart?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    cart.removeFromCart(item.id);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item.name} removed from cart',
                                        ),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: \$${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to checkout screen to collect shipping/billing
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                        child: const Text('Pay & Place Order'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
