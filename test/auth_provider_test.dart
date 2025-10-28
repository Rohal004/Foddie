import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/providers/auth_provider.dart';
import 'package:foodie/models/food_item.dart';
import 'package:foodie/services/local_db.dart';

class FakeLocalStorage implements LocalStorage {
  final Map<String, Map<String, dynamic>> _users = {};
  int _nextId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<int> createUser(String email, String password) async {
    final id = _nextId++;
    _users[email] = {'id': id, 'email': email, 'passwordHash': password};
    return id;
  }

  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return _users[email];
  }

  @override
  Future<Map<String, dynamic>?> authenticate(
    String email,
    String password,
  ) async {
    final u = _users[email];
    if (u == null) return null;
    if (u['passwordHash'] == password) return u;
    return null;
  }

  // Unused in this test
  @override
  Future<List<FoodItem>> getFoods() async => [];
  @override
  Future<void> placeOrder(
    int userId,
    List<FoodItem> items,
    double total,
  ) async {}
  @override
  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async => [];

  // Added to satisfy updated LocalStorage interface
  @override
  Future<Map<String, dynamic>?> getUserById(int id) async {
    for (final u in _users.values) {
      if (u['id'] == id) return u;
    }
    return null;
  }

  @override
  Future<void> updateUserDetails(
    int userId,
    Map<String, dynamic> details,
  ) async {
    for (final key in _users.keys) {
      final u = _users[key]!;
      if (u['id'] == userId) {
        u.addAll(details);
        return;
      }
    }
  }
}

void main() {
  // Initialize bindings for platform channels used by packages like fluttertoast
  TestWidgetsFlutterBinding.ensureInitialized();
  test('signup and login flow (fake storage)', () async {
    final fake = FakeLocalStorage();
    // pass a no-op onMessage callback to avoid platform channel calls (fluttertoast)
    final auth = AuthProvider(fake, (String _) {});

    final signup = await auth.signup('a@example.com', 'pass');
    expect(signup, isTrue);

    final login = await auth.login('a@example.com', 'pass');
    expect(login, isTrue);
    expect(auth.isLoggedIn, isTrue);
  });
}
