import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/food_item.dart';
import 'local_db.dart';

class LocalDBService {
  // Backwards-compatible class name; uses LocalDB or InMemoryLocalStorage depending on platform.
  final LocalStorage _local;

  LocalDBService() : _local = (kIsWeb ? InMemoryLocalStorage() : LocalDB());

  Future<List<FoodItem>> getFoods() async => _local.getFoods();

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    final uid = int.tryParse(userId) ?? 0;
    return await _local.getUserById(uid);
  }

  Future<void> updateUserDetails(
    String userId,
    Map<String, dynamic> details,
  ) async {
    final uid = int.tryParse(userId) ?? 0;
    await _local.updateUserDetails(uid, details);
  }

  Future<void> placeOrder(
    String userId,
    List<FoodItem> items,
    double total,
  ) async {
    final uid = int.tryParse(userId) ?? 0;
    await _local.placeOrder(uid, items, total);
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final uid = int.tryParse(userId) ?? 0;
    return _local.getUserOrders(uid);
  }
}
