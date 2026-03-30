import 'package:flutter/foundation.dart';
import 'package:stresspredictor/models/auth_user.dart';
import 'package:stresspredictor/services/auth_service.dart';

/// Manages authentication state for the whole app.
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService.instance;

  AuthUser? _currentUser;
  bool _isLoading = true; // true while we check initial session on app start
  String? _error;

  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Call once at app start to restore a persisted session.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _service.currentUser();
    _isLoading = false;
    notifyListeners();
  }

  /// Register a new account and log in automatically.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _service.register(
        name: name,
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log in with existing credentials.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _service.login(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log out the current user.
  Future<void> logout() async {
    await _service.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
