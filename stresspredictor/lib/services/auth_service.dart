import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stresspredictor/models/auth_user.dart';

/// Handles local authentication using SharedPreferences.
/// Passwords are hashed with SHA-256 before storage.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_session_email';

  // ── Password hashing ──────────────────────────────────────────────────────

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ── User list persistence ─────────────────────────────────────────────────

  Future<List<AuthUser>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_usersKey) ?? [];
    return raw
        .map((s) => AuthUser.fromJsonString(s))
        .whereType<AuthUser>()
        .toList();
  }

  Future<void> _saveUsers(List<AuthUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _usersKey, users.map((u) => u.toJsonString()).toList());
  }

  // ── Session ───────────────────────────────────────────────────────────────

  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the currently logged-in user, or null if no session.
  Future<AuthUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if a valid session exists.
  Future<bool> get isLoggedIn async => await currentUser() != null;

  /// Registers a new user. Throws [AuthException] if email already taken.
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final emailLower = email.trim().toLowerCase();

    if (users.any((u) => u.email.toLowerCase() == emailLower)) {
      throw AuthException('An account with this email already exists.');
    }

    final user = AuthUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: emailLower,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    users.add(user);
    await _saveUsers(users);
    await _saveSession(user.email);
    return user;
  }

  /// Logs in an existing user. Throws [AuthException] on failure.
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final emailLower = email.trim().toLowerCase();
    final hash = _hashPassword(password);

    try {
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == emailLower && u.passwordHash == hash,
      );
      await _saveSession(user.email);
      return user;
    } catch (_) {
      throw AuthException('Incorrect email or password.');
    }
  }

  /// Logs the current user out.
  Future<void> logout() async {
    await _clearSession();
  }
}

/// Typed exception for authentication errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
