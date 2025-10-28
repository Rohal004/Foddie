import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/local_db.dart';

/// AuthProvider manages authentication state. It accepts an optional
/// LocalStorage for dependency injection (tests) and an optional
/// onMessage callback used to surface messages. If onMessage is not
/// provided, it falls back to Fluttertoast.
class AuthProvider with ChangeNotifier {
  final LocalStorage _db;
  final void Function(String)? _onMessage;
  AuthProvider([LocalStorage? storage, void Function(String)? onMessage])
    : _db = storage ?? (kIsWeb ? InMemoryLocalStorage() : LocalDB()),
      _onMessage = onMessage;
  Map<String, dynamic>? _user;

  String get userId => _user?['id']?.toString() ?? '';
  String get userEmail => _user?['email'] ?? '';

  bool get isLoggedIn => _user != null;

  /// Attempts to login. Returns true when successful.
  Future<bool> login(String email, String password) async {
    try {
      final user = await _db.authenticate(email, password);
      if (user == null) {
        final onMsg = _onMessage;
        if (onMsg != null) {
          onMsg('Invalid credentials');
        } else {
          Fluttertoast.showToast(msg: 'Invalid credentials');
        }
        return false;
      }
      _user = user;
      notifyListeners();
      final onMsg = _onMessage;
      if (onMsg != null) {
        onMsg('Login Successful');
      } else {
        Fluttertoast.showToast(msg: 'Login Successful');
      }
      return true;
    } catch (e) {
      final onMsg = _onMessage;
      if (onMsg != null) {
        onMsg(e.toString());
      } else {
        Fluttertoast.showToast(msg: e.toString());
      }
      return false;
    }
  }

  /// Attempts to sign up. Returns true when successful.
  Future<bool> signup(String email, String password) async {
    try {
      final existing = await _db.getUserByEmail(email);
      if (existing != null) {
        final onMsg = _onMessage;
        if (onMsg != null) {
          onMsg('User already exists');
        } else {
          Fluttertoast.showToast(msg: 'User already exists');
        }
        return false;
      }
      final id = await _db.createUser(email, password);
      _user = {'id': id, 'email': email};
      notifyListeners();
      final onMsg2 = _onMessage;
      if (onMsg2 != null) {
        onMsg2('Account Created');
      } else {
        Fluttertoast.showToast(msg: 'Account Created');
      }
      return true;
    } catch (e) {
      final onMsg3 = _onMessage;
      if (onMsg3 != null) {
        onMsg3(e.toString());
      } else {
        Fluttertoast.showToast(msg: e.toString());
      }
      return false;
    }
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }
}
