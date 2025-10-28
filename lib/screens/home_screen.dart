import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/safe_asset_image.dart';
// removed unused imports after switching to Image.asset for assets
import '../services/local_db_service.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../utils/responsive.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/animated_logo.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LocalDBService();
    final cart = Provider.of<CartProvider>(context);

    final crossAxis = Responsive.isTablet(context) ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            const AnimatedLogo(size: 28),
            const SizedBox(width: 8),
            const Text('Foddie'),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
      body: FutureBuilder<List<FoodItem>>(
        future: service.getFoods(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading menu"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final foods = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxis,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: Responsive.isTablet(context) ? 1.2 : 1.7,
            ),
            itemCount: foods.length,
            itemBuilder: (ctx, i) {
              final f = foods[i];
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: (() {
                          final url = (f.imageUrl).trim();
                          // Only allow packaged asset paths and verify common prefix
                          final isAsset =
                              url.isNotEmpty &&
                              url.startsWith('assets/images/');
                          final assetUrl = isAsset
                              ? url
                              : 'assets/images/cheese_pizza.png';
                          return SafeAssetImage(assetUrl);
                        })(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            f.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${f.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  cart.addToCart(f);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Added to cart"),
                                      duration: Duration(seconds: 5),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.shopping_bag),
        label: Text(
          '${cart.items.length} • \$${cart.total.toStringAsFixed(2)}',
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
      ),
    );
  }
}
