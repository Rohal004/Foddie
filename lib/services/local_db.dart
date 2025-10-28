import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';

import '../models/food_item.dart';

/// Simple in-memory implementation for platforms like Web where sqflite is
/// not available. This mirrors the LocalStorage API.
class InMemoryLocalStorage implements LocalStorage {
  final Map<int, Map<String, dynamic>> _users = {};
  final List<Map<String, dynamic>> _orders = [];
  final List<FoodItem> _foods;
  int _idCounter = 1;

  InMemoryLocalStorage() : _foods = List.unmodifiable(_seedFoodsStatic());

  @override
  Future<void> init() async {}

  String _hashPassword(String password) =>
      BCrypt.hashpw(password, BCrypt.gensalt());

  @override
  Future<int> createUser(String email, String password) async {
    // Ensure unique
    final exists = _users.values.any(
      (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      throw Exception('User already exists');
    }
    final id = _idCounter++;
    _users[id] = {
      'id': id,
      'email': email,
      'passwordHash': _hashPassword(password),
      'firstName': null,
      'lastName': null,
      'address': null,
      'city': null,
      'phone': null,
    };
    return id;
  }

  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      return _users.values.firstWhere(
        (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserById(int id) async {
    return _users[id];
  }

  @override
  Future<void> updateUserDetails(
    int userId,
    Map<String, dynamic> details,
  ) async {
    final u = _users[userId];
    if (u == null) return;
    u.addAll(details);
  }

  @override
  Future<Map<String, dynamic>?> authenticate(
    String email,
    String password,
  ) async {
    final u = await getUserByEmail(email);
    if (u == null) return null;
    final stored = u['passwordHash'] as String?;
    if (stored == null) return null;
    final ok = BCrypt.checkpw(password, stored);
    return ok ? u : null;
  }

  @override
  Future<List<FoodItem>> getFoods() async => _foods;

  @override
  Future<void> placeOrder(
    int userId,
    List<FoodItem> items,
    double total,
  ) async {
    _orders.add({
      'id': _orders.length + 1,
      'userId': userId,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'total': total,
      'status': 'Pending',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    final list = _orders.where((o) => o['userId'] == userId).toList().reversed;
    return list.map((r) {
      final items = (jsonDecode(r['items'] as String) as List)
          .map((m) => FoodItem.fromMap(Map<String, dynamic>.from(m), ''))
          .toList();
      return {
        'id': r['id'],
        'userId': r['userId'],
        'items': items,
        'total': r['total'],
        'status': r['status'],
        'timestamp': r['timestamp'],
      };
    }).toList();
  }

  static List<String> _assetFileNamesStatic() {
    return [
      'cheese_pizza.png',
      'burger.png',
      'sushi.png',
      'pasta_carbonara.png',
      'caesar_salad.png',
      'tacos.png',
      'pad_thai.png',
      'ramen.png',
      'grilled_salmon.png',
      'steak.png',
      'chicken_wings.png',
      'veggie_wrap.png',
      'falafel_bowl.png',
      'pancakes.png',
      'ice_cream.png',
      'donut.png',
      'bbq_ribs.png',
      'curry.png',
      'gyros.png',
      'fish_and_chips.png',
    ];
  }

  static List<FoodItem> _seedFoodsStatic() {
    final names = [
      'Cheese Pizza',
      'Burger',
      'Sushi',
      'Pasta Carbonara',
      'Caesar Salad',
      'Tacos',
      'Pad Thai',
      'Ramen',
      'Grilled Salmon',
      'Steak',
      'Chicken Wings',
      'Veggie Wrap',
      'Falafel Bowl',
      'Pancakes',
      'Ice Cream',
      'Donut',
      'BBQ Ribs',
      'Curry',
      'Gyros',
      'Fish & Chips',
    ];

    final descriptions = [
      'Delicious cheese pizza',
      'Juicy burger',
      'Fresh sushi',
      'Creamy pasta carbonara',
      'Crisp Caesar salad',
      'Spicy and zesty tacos',
      'Classic Thai noodles',
      'Warm comforting ramen',
      'Grilled salmon fillet',
      'Premium grilled steak',
      'Crispy chicken wings',
      'Healthy veggie wrap',
      'Mediterranean falafel bowl',
      'Fluffy pancakes with syrup',
      'Creamy ice cream scoop',
      'Glazed donut',
      'Slow-cooked BBQ ribs',
      'Aromatic curry',
      'Greek style gyros',
      'Classic fish and chips',
    ];

    final prices = [
      9.99,
      7.49,
      12.5,
      11.0,
      6.5,
      8.0,
      10.0,
      9.5,
      14.0,
      18.0,
      7.99,
      6.99,
      9.0,
      5.5,
      3.99,
      2.5,
      16.0,
      12.0,
      8.5,
      9.25,
    ];

    final files = _assetFileNamesStatic();

    return List<FoodItem>.generate(20, (i) {
      return FoodItem(
        id: (i + 1).toString(),
        name: names[i],
        description: descriptions[i],
        price: prices[i],
        imageUrl: 'assets/images/${files[i]}',
      );
    });
  }
}

/// Minimal interface for local storage used by the app.
abstract class LocalStorage {
  Future<void> init();
  Future<int> createUser(String email, String password);
  Future<Map<String, dynamic>?> getUserByEmail(String email);
  Future<Map<String, dynamic>?> getUserById(int id);
  Future<void> updateUserDetails(int userId, Map<String, dynamic> details);
  Future<Map<String, dynamic>?> authenticate(String email, String password);
  Future<List<FoodItem>> getFoods();
  Future<void> placeOrder(int userId, List<FoodItem> items, double total);
  Future<List<Map<String, dynamic>>> getUserOrders(int userId);
}

/// SQLite-backed implementation for platforms that support sqflite.
class LocalDB implements LocalStorage {
  static final LocalDB _instance = LocalDB._internal();
  factory LocalDB() => _instance;
  LocalDB._internal();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;

    // Initialize only on platforms that support sqflite. If path_provider
    // or sqflite are not available on the platform, callers should use the
    // in-memory fallback instead.
    final docs = await getApplicationDocumentsDirectory();
    final path = join(docs.path, 'foodie.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            passwordHash TEXT,
            firstName TEXT,
            lastName TEXT,
            address TEXT,
            city TEXT,
            phone TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE foods (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            price REAL,
            imageUrl TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            items TEXT,
            total REAL,
            status TEXT,
            timestamp INTEGER
          )
        ''');

        // Seed sample foods using packaged assets (assets/images/*).
        final seed = _seedFoods();
        for (final f in seed) {
          await db.insert('foods', {
            'id': f.id,
            'name': f.name,
            'description': f.description,
            'price': f.price,
            'imageUrl': f.imageUrl,
          });
        }
      },
    );

    return _db!;
  }

  String _hashPassword(String password) =>
      BCrypt.hashpw(password, BCrypt.gensalt());

  @override
  Future<void> init() async {
    // Initialize DB only on non-web platforms.
    if (!kIsWeb) {
      await _database;
    }
  }

  @override
  Future<int> createUser(String email, String password) async {
    final db = await _database;
    final hash = _hashPassword(password);
    return await db.insert('users', {
      'email': email,
      'passwordHash': hash,
      'firstName': null,
      'lastName': null,
      'address': null,
      'city': null,
      'phone': null,
    });
  }

  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  @override
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await _database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  @override
  Future<void> updateUserDetails(
    int userId,
    Map<String, dynamic> details,
  ) async {
    final db = await _database;
    await db.update('users', details, where: 'id = ?', whereArgs: [userId]);
  }

  @override
  Future<Map<String, dynamic>?> authenticate(
    String email,
    String password,
  ) async {
    final user = await getUserByEmail(email);
    if (user == null) return null;
    final stored = user['passwordHash'] as String?;
    if (stored == null) return null;
    final ok = BCrypt.checkpw(password, stored);
    if (ok) return user;
    return null;
  }

  /// Returns foods seeded in DB or maps legacy rows to packaged assets.
  @override
  Future<List<FoodItem>> getFoods() async {
    final db = await _database;
    final rows = await db.query('foods');
    if (rows.isEmpty) return List.unmodifiable(_seedFoods());

    final fileNames = _assetFileNames();

    return rows.map((r) {
      final idStr = (r['id'] ?? '').toString();
      final name = r['name'] as String? ?? '';
      final desc = r['description'] as String? ?? '';
      final dynamic rawPrice = r['price'];
      final double price = rawPrice is num
          ? rawPrice.toDouble()
          : (double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0);
      var imageUrl = (r['imageUrl'] as String?) ?? '';

      // If imageUrl is a simple numeric legacy id, map to asset filename.
      final numeric = int.tryParse(imageUrl.trim());
      if (numeric != null && numeric >= 1 && numeric <= fileNames.length) {
        imageUrl = 'assets/images/${fileNames[numeric - 1]}';
      }

      // If still empty, try mapping using the row id.
      if (imageUrl.trim().isEmpty) {
        final rowId = int.tryParse(idStr);
        if (rowId != null && rowId >= 1 && rowId <= fileNames.length) {
          imageUrl = 'assets/images/${fileNames[rowId - 1]}';
        }
      }

      // Final fallback: use a guaranteed packaged asset so Image.asset succeeds.
      if (imageUrl.trim().isEmpty) {
        imageUrl = 'assets/images/cheese_pizza.png';
      }

      final map = {
        'name': name,
        'description': desc,
        'price': price,
        'imageUrl': imageUrl,
      };
      return FoodItem.fromMap(map, idStr);
    }).toList();
  }

  @override
  Future<void> placeOrder(
    int userId,
    List<FoodItem> items,
    double total,
  ) async {
    final db = await _database;
    await db.insert('orders', {
      'userId': userId,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'total': total,
      'status': 'Pending',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    final db = await _database;
    final rows = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return rows.map((r) {
      final items = (jsonDecode(r['items'] as String) as List)
          .map((m) => FoodItem.fromMap(Map<String, dynamic>.from(m), ''))
          .toList();
      return {
        'id': r['id'],
        'userId': r['userId'],
        'items': items,
        'total': r['total'],
        'status': r['status'],
        'timestamp': r['timestamp'],
      };
    }).toList();
  }

  List<String> _assetFileNames() {
    return [
      'cheese_pizza.png',
      'burger.png',
      'sushi.png',
      'pasta_carbonara.png',
      'caesar_salad.png',
      'tacos.png',
      'pad_thai.png',
      'ramen.png',
      'grilled_salmon.png',
      'steak.png',
      'chicken_wings.png',
      'veggie_wrap.png',
      'falafel_bowl.png',
      'pancakes.png',
      'ice_cream.png',
      'donut.png',
      'bbq_ribs.png',
      'curry.png',
      'gyros.png',
      'fish_and_chips.png',
    ];
  }

  List<FoodItem> _seedFoods() {
    final names = [
      'Cheese Pizza',
      'Burger',
      'Sushi',
      'Pasta Carbonara',
      'Caesar Salad',
      'Tacos',
      'Pad Thai',
      'Ramen',
      'Grilled Salmon',
      'Steak',
      'Chicken Wings',
      'Veggie Wrap',
      'Falafel Bowl',
      'Pancakes',
      'Ice Cream',
      'Donut',
      'BBQ Ribs',
      'Curry',
      'Gyros',
      'Fish & Chips',
    ];

    final descriptions = [
      'Delicious cheese pizza',
      'Juicy burger',
      'Fresh sushi',
      'Creamy pasta carbonara',
      'Crisp Caesar salad',
      'Spicy and zesty tacos',
      'Classic Thai noodles',
      'Warm comforting ramen',
      'Grilled salmon fillet',
      'Premium grilled steak',
      'Crispy chicken wings',
      'Healthy veggie wrap',
      'Mediterranean falafel bowl',
      'Fluffy pancakes with syrup',
      'Creamy ice cream scoop',
      'Glazed donut',
      'Slow-cooked BBQ ribs',
      'Aromatic curry',
      'Greek style gyros',
      'Classic fish and chips',
    ];

    final prices = [
      9.99,
      7.49,
      12.5,
      11.0,
      6.5,
      8.0,
      10.0,
      9.5,
      14.0,
      18.0,
      7.99,
      6.99,
      9.0,
      5.5,
      3.99,
      2.5,
      16.0,
      12.0,
      8.5,
      9.25,
    ];

    final files = _assetFileNames();

    return List<FoodItem>.generate(20, (i) {
      return FoodItem(
        id: (i + 1).toString(),
        name: names[i],
        description: descriptions[i],
        price: prices[i],
        imageUrl: 'assets/images/${files[i]}',
      );
    });
  }
}
