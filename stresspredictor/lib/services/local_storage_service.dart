import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stresspredictor/models/stress_prediction.dart';
import 'package:stresspredictor/models/user_profile.dart';

/// Persists stress prediction history and user profile to SharedPreferences.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const _historyKey = 'stress_history';
  static const _profileKey = 'user_profile';
  static const _maxHistoryItems = 30;

  // ────────────────────────────── Stress History ──────────────────────────────

  Future<List<StressPrediction>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw.map((e) {
      final json = jsonDecode(e) as Map<String, dynamic>;
      return StressPrediction.fromJson(json);
    }).toList();
  }

  Future<void> saveHistory(List<StressPrediction> history) async {
    final prefs = await SharedPreferences.getInstance();
    final limited = history.take(_maxHistoryItems).toList();
    final raw = limited.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> addPrediction(StressPrediction prediction) async {
    final history = await loadHistory();
    history.insert(0, prediction); // newest first
    await saveHistory(history);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ────────────────────────────── User Profile ────────────────────────────────

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return UserProfile.defaultProfile();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile.fromJson(json);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}
